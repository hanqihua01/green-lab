import multiprocessing
import time

def read_and_write_file(file_path):
    for i in range(2000):
        with open(file_path, 'r') as file:
            content = file.read()
            file.close()
        with open(file_path, 'w') as file:
            file.write(content)
            file.close()

file_paths = ['test0/test0.txt', 'test1/test1.txt', 'test2/test2.txt', 'test3/test3.txt']

if __name__ == '__main__':

    start_time = time.time()

    processes = []
    for file in file_paths:
        process = multiprocessing.Process(target=read_and_write_file, args=(file,))
        processes.append(process)
        process.start()

    for process in processes:
        process.join()

    end_time = time.time()

    print((end_time - start_time) * 1000)
