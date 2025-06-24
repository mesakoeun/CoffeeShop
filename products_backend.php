<?php
header('Content-Type: application/json');
require 'config/db.php'; // Include your database connection file
function handleImageUpload() {
    if (!isset($_FILES['img']) || $_FILES['img']['error'] === UPLOAD_ERR_NO_FILE) {
        return isset($_POST['existing_img']) ? $_POST['existing_img'] : null;
    }

    $target_dir = "uploads/";
    $fileExtension = strtolower(pathinfo($_FILES["img"]["name"], PATHINFO_EXTENSION));
    $newFileName = uniqid() . '.' . $fileExtension;
    $target_file = $target_dir . $newFileName;

    if (move_uploaded_file($_FILES["img"]["tmp_name"], $target_file)) {
        return $newFileName;
    }
    return null;
}

function deleteImage($filename) {
    if ($filename) {
        $file_path = "uploads/" . $filename;
        if (file_exists($file_path)) {
            unlink($file_path);
        }
    }
}

switch($_SERVER['REQUEST_METHOD']) {
    case 'GET':
        if (isset($_GET['id'])) {
            $stmt = $conn->prepare("SELECT * FROM products WHERE ProductID = ?");
            $stmt->bind_param("i", $_GET['id']);
        } else {
            $stmt = $conn->prepare("SELECT * FROM products");
        }
        
        $stmt->execute();
        $result = $stmt->get_result();
        $data = $result->fetch_all(MYSQLI_ASSOC);
        echo json_encode($data);
        break;

    case 'POST':
        // Check if it's actually a PUT request
        if (isset($_POST['_method']) && $_POST['_method'] == 'PUT') {
            // Get current image before update
            $stmt = $conn->prepare("SELECT img FROM products WHERE ProductID = ?");
            $stmt->bind_param("i", $_POST['id']);
            $stmt->execute();
            $result = $stmt->get_result();
            $current_product = $result->fetch_assoc();

            $img_name = handleImageUpload();
            
            if ($img_name) {
                // Delete old image if new image is uploaded
                if ($current_product && $current_product['img']) {
                    deleteImage($current_product['img']);
                }
                
                $stmt = $conn->prepare("UPDATE products SET Name=?, Category=?, Price=?, img=? WHERE ProductID=?");
                $stmt->bind_param("ssdsi", $_POST['name'], $_POST['category'], $_POST['price'], $img_name, $_POST['id']);
            } else {
                // Keep existing image if no new image is uploaded
                $stmt = $conn->prepare("UPDATE products SET Name=?, Category=?, Price=? WHERE ProductID=?");
                $stmt->bind_param("ssdi", $_POST['name'], $_POST['category'], $_POST['price'], $_POST['id']);
            }
            
        } else {
            // Regular POST (Insert)
            $img_name = handleImageUpload();
            $stmt = $conn->prepare("INSERT INTO products (Name, Category, Price, img) VALUES (?, ?, ?, ?)");
            $stmt->bind_param("ssds", $_POST['name'], $_POST['category'], $_POST['price'], $img_name);
        }
        
        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'id' => $conn->insert_id]);
        } else {
            echo json_encode(['error' => $stmt->error]);
        }
        break;

    case 'DELETE':
        parse_str(file_get_contents("php://input"), $_DELETE);
        
        // Get the image filename before deleting the record
        $stmt = $conn->prepare("SELECT img FROM products WHERE ProductID = ?");
        $stmt->bind_param("i", $_DELETE['id']);
        $stmt->execute();
        $result = $stmt->get_result();
        $product = $result->fetch_assoc();

        // Delete the record
        $stmt = $conn->prepare("DELETE FROM products WHERE ProductID = ?");
        $stmt->bind_param("i", $_DELETE['id']);
        
        if ($stmt->execute()) {
            // If record deletion was successful, delete the image file
            if ($product && $product['img']) {
                deleteImage($product['img']);
            }
            echo json_encode(['success' => true]);
        } else {
            echo json_encode(['error' => $stmt->error]);
        }
        break;
}

$conn->close();
?>