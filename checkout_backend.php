<?php
header('Content-Type: application/json');
require 'config/db.php';


if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        // Get the cart items from the POST request
        $cartItems = json_decode(file_get_contents('php://input'), true);
        
        // Clear temporary table first
        $conn->query("TRUNCATE TABLE orderitemstemp");
        
        // Insert items into temporary table
        $stmt = $conn->prepare("INSERT INTO orderitemstemp (ProductID, Quantity) VALUES (?, ?)");
        
        foreach ($cartItems as $productId => $item) {
            $stmt->bind_param("ii", $productId, $item['quantity']);
            $stmt->execute();
        }
        
        // Call the stored procedure (using customer_id = 1 for this example)
        // You should modify this to use actual customer ID from your authentication system
        $customer_id = 5;
        $result = $conn->query("CALL CreateMultiItemOrder($customer_id)");
        
        if ($result) {
            $orderDetails = [];
            do {
                if ($result->num_rows > 0) {
                    while ($row = $result->fetch_assoc()) {
                        $orderDetails[] = $row;
                    }
                }
            } while ($conn->more_results() && $conn->next_result());
            
            echo json_encode([
                'success' => true,
                'message' => 'Order created successfully',
                'orderDetails' => $orderDetails
            ]);
        } else {
            throw new Exception("Failed to create order");
        }
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'error' => $e->getMessage()
        ]);
    }
}

$conn->close();
?>