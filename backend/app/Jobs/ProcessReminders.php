<?php

namespace App\Jobs;

use App\Services\ReminderService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;

class ProcessReminders implements ShouldQueue
{
    use Queueable;

    public function __construct(
        public string $type = 'h-1',
    ) {}

    public function handle(ReminderService $service): void
    {
        $service->processReminders($this->type);
    }
}
