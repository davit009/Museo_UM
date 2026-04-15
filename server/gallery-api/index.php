<?php

declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Access-Control-Allow-Methods: POST, OPTIONS');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

$baseDir = getenv('GALLERY_ROOT') ?: '/var/www/media/Galeria';
$baseDir = rtrim($baseDir, '/');

function respond(int $status, array $payload): void
{
    http_response_code($status);
    echo json_encode($payload, JSON_UNESCAPED_UNICODE);
    exit;
}

function normalize_relative_path(string $value): string
{
    $value = trim($value);
    $value = str_replace('\\', '/', $value);
    $value = preg_replace('#/+#', '/', $value) ?? '';
    $value = trim($value, '/');

    if ($value === '') {
        return '';
    }

    $parts = explode('/', $value);
    $safeParts = [];

    foreach ($parts as $part) {
        if ($part === '' || $part === '.' || $part === '..') {
            continue;
        }

        // Acepta letras, numeros, espacios, guion, guion bajo, parentesis y punto.
        $clean = preg_replace('/[^A-Za-z0-9 _().\-]/u', '', $part) ?? '';
        $clean = trim($clean);
        if ($clean !== '') {
            $safeParts[] = $clean;
        }
    }

    return implode('/', $safeParts);
}

function full_path(string $baseDir, string $relativePath): string
{
    return $baseDir . '/' . $relativePath;
}

function ensure_inside_base(string $baseDir, string $path): bool
{
    $base = realpath($baseDir);
    if ($base === false) {
        return false;
    }

    $dirToCheck = is_dir($path) ? $path : dirname($path);
    if (!is_dir($dirToCheck)) {
        $dirToCheck = dirname($dirToCheck);
    }

    $real = realpath($dirToCheck);
    if ($real === false) {
        return false;
    }

    return str_starts_with($real, $base);
}

function read_json_body(): array
{
    $raw = file_get_contents('php://input');
    if ($raw === false || $raw === '') {
        return [];
    }

    $decoded = json_decode($raw, true);
    if (!is_array($decoded)) {
        return [];
    }

    return $decoded;
}

function delete_directory_recursive(string $dir): bool
{
    if (!is_dir($dir)) {
        return false;
    }

    $items = scandir($dir);
    if ($items === false) {
        return false;
    }

    foreach ($items as $item) {
        if ($item === '.' || $item === '..') {
            continue;
        }

        $target = $dir . '/' . $item;
        if (is_dir($target)) {
            if (!delete_directory_recursive($target)) {
                return false;
            }
            continue;
        }

        if (!unlink($target)) {
            return false;
        }
    }

    return rmdir($dir);
}

function build_api_path(): string
{
    $uri = $_SERVER['REQUEST_URI'] ?? '/';
    $path = parse_url($uri, PHP_URL_PATH);
    if (!is_string($path)) {
        return '/';
    }

    $marker = '/api/gallery';
    $idx = strpos($path, $marker);
    if ($idx === false) {
        return '/';
    }

    $sub = substr($path, $idx + strlen($marker));
    if ($sub === false || $sub === '') {
        return '/';
    }

    return $sub;
}

if (!is_dir($baseDir)) {
    respond(500, ['ok' => false, 'error' => 'GALLERY_ROOT no existe']);
}

$apiPath = build_api_path();
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if ($method !== 'POST') {
    respond(405, ['ok' => false, 'error' => 'Metodo no permitido']);
}

if ($apiPath === '/folders/create') {
    $body = read_json_body();
    $relative = normalize_relative_path((string)($body['path'] ?? ''));
    if ($relative === '') {
        respond(400, ['ok' => false, 'error' => 'path requerido']);
    }

    $target = full_path($baseDir, $relative);
    if (!ensure_inside_base($baseDir, $target)) {
        respond(403, ['ok' => false, 'error' => 'Ruta invalida']);
    }

    if (is_dir($target)) {
        respond(200, ['ok' => true, 'message' => 'Carpeta ya existe']);
    }

    if (!mkdir($target, 0775, true)) {
        respond(500, ['ok' => false, 'error' => 'No se pudo crear carpeta']);
    }

    respond(200, ['ok' => true]);
}

if ($apiPath === '/folders/rename') {
    $body = read_json_body();
    $from = normalize_relative_path((string)($body['from'] ?? ''));
    $to = normalize_relative_path((string)($body['to'] ?? ''));

    if ($from === '' || $to === '') {
        respond(400, ['ok' => false, 'error' => 'from y to requeridos']);
    }

    $fromPath = full_path($baseDir, $from);
    $toPath = full_path($baseDir, $to);

    if (!is_dir($fromPath)) {
        respond(404, ['ok' => false, 'error' => 'Carpeta origen no existe']);
    }

    if (!ensure_inside_base($baseDir, $fromPath) || !ensure_inside_base($baseDir, $toPath)) {
        respond(403, ['ok' => false, 'error' => 'Ruta invalida']);
    }

    $toParent = dirname($toPath);
    if (!is_dir($toParent) && !mkdir($toParent, 0775, true)) {
        respond(500, ['ok' => false, 'error' => 'No se pudo preparar destino']);
    }

    if (!rename($fromPath, $toPath)) {
        respond(500, ['ok' => false, 'error' => 'No se pudo renombrar carpeta']);
    }

    respond(200, ['ok' => true]);
}

if ($apiPath === '/folders/delete') {
    $body = read_json_body();
    $relative = normalize_relative_path((string)($body['path'] ?? ''));

    if ($relative === '') {
        respond(400, ['ok' => false, 'error' => 'path requerido']);
    }

    $target = full_path($baseDir, $relative);
    if (!is_dir($target)) {
        respond(404, ['ok' => false, 'error' => 'Carpeta no existe']);
    }

    if (!ensure_inside_base($baseDir, $target)) {
        respond(403, ['ok' => false, 'error' => 'Ruta invalida']);
    }

    if (!delete_directory_recursive($target)) {
        respond(500, ['ok' => false, 'error' => 'No se pudo eliminar carpeta']);
    }

    respond(200, ['ok' => true]);
}

if ($apiPath === '/files/upload') {
    $relative = normalize_relative_path((string)($_POST['path'] ?? ''));
    if ($relative === '') {
        respond(400, ['ok' => false, 'error' => 'path requerido']);
    }

    if (!isset($_FILES['file']) || !is_array($_FILES['file'])) {
        respond(400, ['ok' => false, 'error' => 'file requerido']);
    }

    $file = $_FILES['file'];
    $tmpName = $file['tmp_name'] ?? '';
    if (!is_string($tmpName) || $tmpName === '' || !is_uploaded_file($tmpName)) {
        respond(400, ['ok' => false, 'error' => 'Archivo invalido']);
    }

    $ext = strtolower(pathinfo($relative, PATHINFO_EXTENSION));
    $allowed = ['jpg', 'jpeg', 'png', 'webp'];
    if (!in_array($ext, $allowed, true)) {
        respond(400, ['ok' => false, 'error' => 'Extension no permitida']);
    }

    $target = full_path($baseDir, $relative);
    if (!ensure_inside_base($baseDir, $target)) {
        respond(403, ['ok' => false, 'error' => 'Ruta invalida']);
    }

    $parent = dirname($target);
    if (!is_dir($parent) && !mkdir($parent, 0775, true)) {
        respond(500, ['ok' => false, 'error' => 'No se pudo crear directorio destino']);
    }

    if (!move_uploaded_file($tmpName, $target)) {
        respond(500, ['ok' => false, 'error' => 'No se pudo guardar archivo']);
    }

    respond(200, ['ok' => true]);
}

if ($apiPath === '/files/rename') {
    $body = read_json_body();
    $from = normalize_relative_path((string)($body['from'] ?? ''));
    $to = normalize_relative_path((string)($body['to'] ?? ''));

    if ($from === '' || $to === '') {
        respond(400, ['ok' => false, 'error' => 'from y to requeridos']);
    }

    $fromPath = full_path($baseDir, $from);
    $toPath = full_path($baseDir, $to);

    if (!is_file($fromPath)) {
        respond(404, ['ok' => false, 'error' => 'Archivo origen no existe']);
    }

    if (!ensure_inside_base($baseDir, $fromPath) || !ensure_inside_base($baseDir, $toPath)) {
        respond(403, ['ok' => false, 'error' => 'Ruta invalida']);
    }

    $toParent = dirname($toPath);
    if (!is_dir($toParent) && !mkdir($toParent, 0775, true)) {
        respond(500, ['ok' => false, 'error' => 'No se pudo preparar destino']);
    }

    if (!rename($fromPath, $toPath)) {
        respond(500, ['ok' => false, 'error' => 'No se pudo renombrar archivo']);
    }

    respond(200, ['ok' => true]);
}

if ($apiPath === '/files/delete') {
    $body = read_json_body();
    $relative = normalize_relative_path((string)($body['path'] ?? ''));

    if ($relative === '') {
        respond(400, ['ok' => false, 'error' => 'path requerido']);
    }

    $target = full_path($baseDir, $relative);
    if (!is_file($target)) {
        respond(404, ['ok' => false, 'error' => 'Archivo no existe']);
    }

    if (!ensure_inside_base($baseDir, $target)) {
        respond(403, ['ok' => false, 'error' => 'Ruta invalida']);
    }

    if (!unlink($target)) {
        respond(500, ['ok' => false, 'error' => 'No se pudo eliminar archivo']);
    }

    respond(200, ['ok' => true]);
}

respond(404, ['ok' => false, 'error' => 'Endpoint no encontrado']);
