import random
import time
from multiprocessing import Pool

def add_random_numbers(count):
    return sum(random.random() for _ in range(count))

def main():
    process_count = 4
    numbers_per_process = 80000000 // process_count

    start_time = time.time()

    with Pool(process_count) as pool:
        results = pool.map(add_random_numbers, [numbers_per_process] * process_count)

    total_sum = sum(results)

    end_time = time.time()

    print((end_time - start_time) * 1000)

if __name__ == '__main__':
    main()
