<?php

return [
    'driver' => env('WHATSAPP_DRIVER', 'log'),
    'api_key' => env('WHATSAPP_API_KEY', ''),
    'api_url' => env('WHATSAPP_API_URL', ''),

    // WAHA (self-hosted WhatsApp HTTP API) settings — used when driver=waha.
    'waha_url' => env('WAHA_URL', 'http://localhost:3000'),
    'waha_api_key' => env('WAHA_API_KEY', ''),
    'waha_session' => env('WAHA_SESSION', 'default'),
];
