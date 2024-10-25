import random
import time
import threading

def add_random_numbers(count, result, index):
    subtotal = sum(random.random() for _ in range(count))
    result[index] = subtotal

thread_count = 4
numbers_per_thread = 80000000 // thread_count

results = [0] * thread_count
threads = []

start_time = time.time()

for i in range(thread_count):
    thread = threading.Thread(target=add_random_numbers, args=(numbers_per_thread, results, i))
    threads.append(thread)
    thread.start()

for thread in threads:
    thread.join()

total_sum = sum(results)

end_time = time.time()

print((end_time - start_time) * 1000)
