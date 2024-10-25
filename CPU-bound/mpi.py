from mpi4py import MPI
import random
import time

def main():
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    size = comm.Get_size()

    if rank == 0:
        start_time = time.time()

    total_numbers = 80000000
    numbers_per_process = total_numbers // size

    subtotal = sum(random.random() for _ in range(numbers_per_process))

    total_sum = comm.reduce(subtotal, op=MPI.SUM, root=0)

    if rank == 0:
        end_time = time.time()
        print((end_time - start_time) * 1000)

if __name__ == '__main__':
    main()
