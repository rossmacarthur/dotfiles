#!/usr/bin/env python

import click
import codecs
import serial
import sys
import threading

import atexit
import termios
import fcntl


def key_description(character):
    ascii_code = ord(character)
    if ascii_code < 32:
        return 'Ctrl+{:c}'.format(ord('@') + ascii_code)
    else:
        return repr(character)


class Console(object):

    def __init__(self):
        self.byte_output = sys.stdout
        self.output = sys.stdout
        self.fd = sys.stdin.fileno()
        self.old = termios.tcgetattr(self.fd)
        atexit.register(self.cleanup)
        self.enc_stdin = codecs.getreader(sys.stdin.encoding)(sys.stdin)

    def setup(self):
        new = termios.tcgetattr(self.fd)
        new[3] = new[3] & ~termios.ICANON & ~termios.ECHO & ~termios.ISIG
        new[6][termios.VMIN] = 1
        new[6][termios.VTIME] = 0
        termios.tcsetattr(self.fd, termios.TCSANOW, new)

    def cleanup(self):
        termios.tcsetattr(self.fd, termios.TCSAFLUSH, self.old)

    def getkey(self):
        c = self.enc_stdin.read(1)
        if c == unichr(0x7f):
            c = unichr(8)
        return c

    def write_bytes(self, byte_string):
        self.byte_output.write(byte_string)
        self.byte_output.flush()

    def write(self, text):
        self.output.write(text)
        self.output.flush()

    def cancel(self):
        fcntl.ioctl(self.fd, termios.TIOCSTI, b'\0')

    def __enter__(self):
        self.cleanup()
        return self

    def __exit__(self, *args, **kwargs):
        self.setup()


class Nanocom(object):

    def __init__(self, serial_instance):
        self.console = Console()
        self.serial = serial_instance
        self.exit_character = '\x1d'  # Ctrl+]
        self.rx_decoder = codecs.getincrementaldecoder('UTF-8')('replace')
        self.tx_encoder = codecs.getincrementalencoder('UTF-8')('replace')

    def start(self):
        self.alive = True
        self.receiver_thread = threading.Thread(target=self.reader, name='rx')
        self.receiver_thread.daemon = True
        self.receiver_thread.start()
        self.transmitter_thread = threading.Thread(target=self.writer, name='tx')
        self.transmitter_thread.daemon = True
        self.transmitter_thread.start()
        self.console.setup()

    def stop(self):
        self.alive = False

    def join(self):
        self.transmitter_thread.join()
        self.serial.cancel_read()
        self.receiver_thread.join()

    def close(self):
        self.serial.close()

    def reader(self):
        try:
            while self.alive:
                data = self.serial.read(self.serial.in_waiting or 1)
                if data:
                    self.console.write_bytes(self.rx_decoder.decode(data))
        except serial.SerialException:
            self.alive = False
            self.console.cancel()
            raise

    def writer(self):
        try:
            while self.alive:
                try:
                    c = self.console.getkey()
                except KeyboardInterrupt:
                    c = '\x03'  # Ctrl+C
                if not self.alive:
                    break
                if c == self.exit_character:
                    self.stop()
                    break
                else:
                    self.serial.write(self.tx_encoder.encode(c))
        except:
            self.alive = False
            raise


@click.command(context_settings=dict(help_option_names=['-h', '--help']))
@click.option('--port', '-p', type=click.Path(exists=True), help='The device port.')
@click.option('--baudrate', '-b', type=int, default=115200, help='The baudrate of the port.')
def main(port, baudrate):
    serial_instance = serial.serial_for_url(port, baudrate)
    nanocom = Nanocom(serial_instance)
    sys.stderr.write('*** Welcome to Nanocom ***\n')
    sys.stderr.write('*** Use {} to exit ***\n'.format(key_description(nanocom.exit_character)))
    nanocom.start()
    try:
        nanocom.join()
    except KeyboardInterrupt:
        pass
    sys.stderr.write('\n*** Nanocom exit ***\n')
    nanocom.close()


if __name__ == '__main__':
    main()
