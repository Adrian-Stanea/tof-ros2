#include "worker_thread.h"

WorkerThread::WorkerThread(RosTask * rosTask)
: std::thread([this] { this->runTask(); }), m_rosTask(rosTask)
{
}

WorkerThread::~WorkerThread() {}

void WorkerThread::runTask() { m_rosTask->run(); }
