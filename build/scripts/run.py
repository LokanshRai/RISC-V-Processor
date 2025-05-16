from pynq import Overlay
from pathlib import Path
from argparse import ArgumentParser as AP
from pynq import allocate
import numpy as np
import logging

logging.getLogger().setLevel(logging.DEBUG)

def extract_trace(array, path="output.trace", verbose=True):
    nt = len(array)
    res = []
    for i in range(0, nt, 2):
        pc = int(array[i]) & 0xffffffff;
        wval = int(array[i]) >> 32
        dst = int(array[i + 1]) & 0x1f
        we = 0 if (int(array[i + 1]) & 0x20) == 0  else 1
        s = "[W] {:08x} {:01x} {:02x} {:08x}".format(pc, we, dst, wval)
        res.append(s)
        # logging.info(s)
    path.write_text('\n'.join(res))

parser = AP()
parser.add_argument('program')
parser.add_argument('--trace-len', default=10240, type=int, help="Number of trace entries to collect")
parser.add_argument('--debug', default=False, action="store_true", help="When enabled, wait for user input before pulling the reset")
args = parser.parse_args()



logging.info("Flashing bitstream")

ov = Overlay('overlay.bit')

logging.info("Done")

if args.debug:
    input("Press Enter to continue after mouning the probes...")

dma = ov.axi_dma_0
dma_send = dma.sendchannel
dma_recv = dma.recvchannel
gpio = ov.axi_gpio_0

program_path = Path(args.program)
prog = program_path.read_text()
prog = list(map(lambda x: int(x.strip(), 16), prog.strip().split('\n')))
prog_addr = list(map(lambda x: x * 4 + 0x01000000, range(len(prog))))
prog_cma = allocate(shape=(len(prog) * 2, ), dtype=np.uint32)
prog_cma[1::2] = prog[:]
prog_cma[::2] = prog_addr[:]
trace = allocate(shape=(args.trace_len * 2, ), dtype=np.uint64)  # 128-bit / entry

# transfer program
logging.info("Loading program")
dma_send.transfer(prog_cma)
dma_send.wait()

# pull reset
dma_recv.transfer(trace)
logging.info("Releasing reset")
gpio.channel1.write(0, 0xffffffff)
dma_recv.wait()

logging.info("Reading trace")
trace_fn = program_path.with_suffix('.trace')
extract_trace(trace, trace_fn)
logging.info("Done")
