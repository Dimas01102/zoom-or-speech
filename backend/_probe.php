<?php

require __DIR__ . '/vendor/autoload.php';

$app = require __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

$request = Illuminate\Http\Request::create('/admin/login', 'GET');
try {
    $response = $kernel->handle($request);
    $content = $response->getContent();
    file_put_contents(__DIR__ . '/storage/login_dump.html', $content);
    echo 'STATUS=' . $response->getStatusCode() . PHP_EOL;
    echo 'LEN=' . strlen($content) . PHP_EOL;
} catch (\Throwable $e) {
    echo 'ERR: ' . $e->getMessage() . PHP_EOL;
}
