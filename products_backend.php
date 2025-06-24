<?php
header('Content-Type: application/json');
require 'config/db.php';

function respond($data, $code = 200) {
    http_response_code($code);
    echo json_encode($data);
    exit;
}

function handleImageUpload() {
    if (!isset($_FILES['img']) || $_FILES['img']['error'] === UPLOAD_ERR_NO_FILE) {
        return $_POST['existing_img'] ?? null;
    }

    $target_dir = "uploads/";
    $fileExtension = strtolower(pathinfo($_FILES["img"]["name"], PATHINFO_EXTENSION));
    $allowed = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    if (!in_array($fileExtension, $allowed)) {
        respond(['error' => 'Invalid file type.'], 400);
    }
    if ($_FILES["img"]["size"] > 2 * 1024 * 1024) { // 2MB limit
        respond(['error' => 'File too large.'], 400);
    }

    $newFileName = uniqid() . '.' . $fileExtension;
    $target_file = $target_dir . $newFileName;

    if (!move_uploaded_file($_FILES["img"]["tmp_name"], $target_file)) {
        respond(['error' => 'Failed to upload image.'], 500);
    }
    return $newFileName;
}

function deleteImage($filename) {
    if ($filename) {
        $file_path = "uploads/" . $filename;
        if (file_exists($file_path)) {
            unlink($file_path);
        }
    }
}

function getProductById($conn, $id) {
    $stmt = $conn->prepare("SELECT * FROM products WHERE ProductID = ?");
    $stmt->bind_param("i", $id);
    $stmt->execute();
    return $stmt->get_result()->fetch_assoc();
}

switch($_SERVER['REQUEST_METHOD']) {
    case 'GET':
        if (isset($_GET['id'])) {
            $id = intval($_GET['id']);
            $product = getProductById($conn, $id);
            respond($product ?: []);
        } else {
            $result = $conn->query("SELECT * FROM products");
            $data = $result->fetch_all(MYSQLI_ASSOC);
            respond($data);
        }
        break;

    case 'POST':
        // Update
        if (isset($_POST['_method']) && $_POST['_method'] === 'PUT') {
            $id = intval($_POST['id']);
            $name = trim($_POST['name']);
            $category = trim($_POST['category']);
            $price = floatval($_POST['price']);

            $current_product = getProductById($conn, $id);
            if (!$current_product) respond(['error' => 'Product not found.'], 404);

            $img_name = handleImageUpload();

            if ($img_name && $current_product['img']) {
                deleteImage($current_product['img']);
            }

            if ($img_name) {
                $stmt = $conn->prepare("UPDATE products SET Name=?, Category=?, Price=?, img=? WHERE ProductID=?");
                $stmt->bind_param("ssdsi", $name, $category, $price, $img_name, $id);
            } else {
                $stmt = $conn->prepare("UPDATE products SET Name=?, Category=?, Price=? WHERE ProductID=?");
                $stmt->bind_param("ssdi", $name, $category, $price, $id);
            }

            if ($stmt->execute()) {
                respond(['success' => true, 'id' => $id]);
            } else {
                respond(['error' => $stmt->error], 500);
            }
        } else {
            // Insert
            $name = trim($_POST['name']);
            $category = trim($_POST['category']);
            $price = floatval($_POST['price']);
            $img_name = handleImageUpload();

            $stmt = $conn->prepare("INSERT INTO products (Name, Category, Price, img) VALUES (?, ?, ?, ?)");
            $stmt->bind_param("ssds", $name, $category, $price, $img_name);

            if ($stmt->execute()) {
                respond(['success' => true, 'id' => $conn->insert_id], 201);
            } else {
                respond(['error' => $stmt->error], 500);
            }
        }
        break;

    case 'DELETE':
        parse_str(file_get_contents("php://input"), $_DELETE);
        $id = intval($_DELETE['id'] ?? 0);
        if (!$id) respond(['error' => 'Missing id.'], 400);

        $product = getProductById($conn, $id);
        if (!$product) respond(['error' => 'Product not found.'], 404);

        $stmt = $conn->prepare("DELETE FROM products WHERE ProductID = ?");
        $stmt->bind_param("i", $id);

        if ($stmt->execute()) {
            if ($product['img']) deleteImage($product['img']);
            respond(['success' => true]);
        } else {
            respond(['error' => $stmt->error], 500);
        }
        break;

    default:
        respond(['error' => 'Method not allowed.'], 405);
}

$conn->close();
?>