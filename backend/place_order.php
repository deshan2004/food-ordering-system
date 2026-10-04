<?php
require_once 'db.php';

$data = json_decode(file_get_contents("php://input"), true);

if (!$data || empty($data['items']) || empty($data['total_amount'])) {
    echo json_encode(["status" => false, "message" => "Invalid order payload"]);
    exit();
}

$orderId = "ORD-" . time() . "-" . rand(100, 999);
$userId = isset($data['user_id']) ? $data['user_id'] : 'guest';
$userName = isset($data['user_name']) ? $data['user_name'] : 'Guest Customer';
$userEmail = isset($data['user_email']) ? $data['user_email'] : 'guest@bonchi.lk';
$totalAmount = floatval($data['total_amount']);
$deliveryAddress = isset($data['delivery_address']) ? $data['delivery_address'] : 'No. 45, Galle Road, Colombo 03';
$paymentMethod = isset($data['payment_method']) ? $data['payment_method'] : 'Cash on Delivery';

// Insert order
$stmt = $conn->prepare("INSERT INTO orders (id, user_id, user_name, user_email, total_amount, delivery_address, payment_method, status) VALUES (?, ?, ?, ?, ?, ?, ?, 'Preparing')");
$stmt->bind_param("ssssdss", $orderId, $userId, $userName, $userEmail, $totalAmount, $deliveryAddress, $paymentMethod);

if ($stmt->execute()) {
    // Insert order items
    $itemStmt = $conn->prepare("INSERT INTO order_items (order_id, food_id, food_name, quantity, price) VALUES (?, ?, ?, ?, ?)");
    foreach ($data['items'] as $item) {
        $foodId = $item['id'];
        $foodName = $item['name'];
        $qty = intval($item['quantity']);
        $price = floatval($item['price']);
        $itemStmt->bind_param("sssdd", $orderId, $foodId, $foodName, $qty, $price);
        $itemStmt->execute();
    }
    $itemStmt->close();

    echo json_encode([
        "status" => true,
        "message" => "Order placed successfully in MySQL!",
        "order_id" => $orderId
    ]);
} else {
    echo json_encode(["status" => false, "message" => "Failed to place order: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
