import psutil
import time
import sys

def monitor_processes(pid_list):
    process_stats = {}
    for pid in pid_list:
        try:
            process = psutil.Process(pid)
            process_stats[pid] = {
                'user_time': 0.0,
                'system_time': 0.0,
                'io_wait_time': 0.0
            }
        except psutil.NoSuchProcess:
            exit(f"Process {pid} does not exist.")
    
    while pid_list:
        for pid in pid_list:
            try:
                process = psutil.Process(pid)
                cpu_times = process.cpu_times()

                process_stats[pid]['user_time'] = cpu_times.user
                process_stats[pid]['system_time'] = cpu_times.system
                process_stats[pid]['io_wait_time'] = cpu_times.iowait
            
            except psutil.NoSuchProcess:
                pid_list.remove(pid)

        time.sleep(0.5)

    return process_stats

if __name__ == "__main__":
    pid_list = [int(pid) for pid in sys.argv[1:]]
    process_stats = monitor_processes(pid_list)
    total_user_time = 0.0
    total_system_time = 0.0
    total_io_wait_time = 0.0
    for pid, stats in process_stats.items():
        total_user_time += stats['user_time']
        total_system_time += stats['system_time']
        total_io_wait_time += stats['io_wait_time']
    print(round(total_user_time, 2))
    print(round(total_system_time, 2))
    print(round(total_io_wait_time, 2))
