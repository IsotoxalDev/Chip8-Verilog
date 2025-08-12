import serial
import serial.tools.list_ports
import sys
import pygame

START_BYTE = 0xF0
END_BYTE = 0xF1
ESCAPE_BYTE = 0xF2
START_GAME_BYTE = 0xAA
WIDTH = 64
BYTES_PER_ROW = WIDTH // 8

def list_ports():
    ports = serial.tools.list_ports.comports()
    for i, port in enumerate(ports):
        print(f"{i}: {port.device} - {port.description}")
    return ports

def select_port(ports):
    while True:
        try:
            idx = int(input("Select a port by index: "))
            return ports[idx].device
        except (ValueError, IndexError):
            print("Invalid selection. Try again.")

def receive_data(port):
    ser = serial.Serial(port, baudrate=115200, timeout=1)
    buffer = []
    escape_next = False
    started = False

    print("Waiting for data...")
    while True:
        byte = ser.read(1)
        if not byte:
            continue

        b = byte[0]

        if not started:
            if b == START_BYTE:
                started = True
                print("Start byte received. Receiving data...")
            continue

        if b == START_GAME_BYTE:
            print("Start game byte received. Ending transmission.")
            break

        if b == END_BYTE:
            print("End byte received.")
            continue

        if b == ESCAPE_BYTE:
            escape_next = True
            continue

        if escape_next:
            b ^= 0x20
            escape_next = False

        buffer.append(b)

    ser.close()

    with open("received.bin", "wb") as f:
        f.write(bytearray(buffer))

    print(f"Data saved to received.bin ({len(buffer)} bytes)")
    return buffer

def display_image(buffer):
    rows = len(buffer) // BYTES_PER_ROW
    HEIGHT = rows
    SCALE = 10

    pygame.init()
    screen = pygame.display.set_mode((WIDTH * SCALE, HEIGHT * SCALE))
    pygame.display.set_caption("IBMLOGO.bin Viewer")

    clock = pygame.time.Clock()

    running = True
    while running:
        screen.fill((0, 0, 0))

        for y in range(rows):
            for x_byte in range(BYTES_PER_ROW):
                byte = buffer[y * BYTES_PER_ROW + x_byte]
                for bit in range(8):
                    pixel = (byte >> (7 - bit)) & 1
                    if pixel:
                        px = (x_byte * 8 + bit) * SCALE
                        py = y * SCALE
                        pygame.draw.rect(screen, (255, 255, 255), (px, py, SCALE, SCALE))

        pygame.display.flip()

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

        clock.tick(30)

    pygame.quit()

if __name__ == "__main__":
    print("Available serial ports:")
    ports = list_ports()
    if not ports:
        print("No serial ports found.")
        sys.exit(1)

    port = select_port(ports)
    input(f"Press Enter to start receiving on {port}...")

    data = receive_data(port)
    display_image(data)
