<?php

use App\Jobs\ProcessReminders;
use Illuminate\Support\Facades\Schedule;

Schedule::job(new ProcessReminders('h-1'))->dailyAt('09:00');
Schedule::job(new ProcessReminders('h-0'))->dailyAt('07:00');
