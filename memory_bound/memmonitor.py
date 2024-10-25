import psutil
import time
import sys

# def get_process_memory(pids):
#     total_memory = 0
#     running_pids = []
#     for pid in pids:
#         try:
#             p = psutil.Process(pid)
#             if p.is_running():
#                 mem_info = p.memory_info()
#                 total_memory += mem_info.rss  # 以字节为单位
#                 running_pids.append(pid)
#         except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
#             # 进程不存在或者访问被拒绝，忽略
#             pass
#     return total_memory, running_pids

def get_pss_memory(pid):
    pss_memory = 0
    try:
        with open(f"/proc/{pid}/smaps", 'r') as f:
            for line in f:
                if line.startswith("Pss:"):
                    pss_memory += int(line.split()[1])
    except (FileNotFoundError, ProcessLookupError, PermissionError):
        pass
    
    return pss_memory * 1024

def get_process_memory(pids):
    total_memory = 0
    running_pids = []
    
    for pid in pids:
        pss_memory = get_pss_memory(pid)
        if pss_memory > 0:
            total_memory += pss_memory
            running_pids.append(pid)
    
    return total_memory, running_pids

def monitor_processes(pids):
    memory_snapshots = []

    while pids:
        total_memory, running_pids = get_process_memory(pids)
        
        memory_snapshots.append(total_memory)
        
        pids = running_pids
        
        time.sleep(1)

    avg_memory = sum(memory_snapshots) / len(memory_snapshots) if memory_snapshots else 0

    return avg_memory

if __name__ == "__main__":
    pid_list = [int(pid) for pid in sys.argv[1:]]

    avg_memory_usage = monitor_processes(pid_list)
    print(round(avg_memory_usage, 2))
