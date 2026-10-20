<?php

use App\Jobs\ProcessReminders;
use Illuminate\Support\Facades\Schedule;

// app.timezone = UTC, jadi jam pengingat dikunci ke WIB secara eksplisit.
Schedule::job(new ProcessReminders('h-1'))->dailyAt('09:00')->timezone('Asia/Jakarta');
Schedule::job(new ProcessReminders('h-0'))->dailyAt('07:00')->timezone('Asia/Jakarta');

// Alarm WAHA: notifikasi ke super admin bila session WhatsApp tidak WORKING.
Schedule::command('whatsapp:check-status')->everyFiveMinutes()->withoutOverlapping();
