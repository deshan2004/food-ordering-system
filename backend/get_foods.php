<?php
require_once 'db.php';

$sql = "SELECT * FROM food_items";
$result = $conn->query($sql);

$foods = array();

if ($result && $result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $row['priceLkr'] = floatval($row['priceLkr']);
        $row['rating'] = floatval($row['rating']);
        $row['deliveryFeeLkr'] = floatval($row['deliveryFeeLkr']);
        $row['signatureItemPriceLkr'] = floatval($row['signatureItemPriceLkr']);
        $row['isOpenNow'] = (bool)$row['isOpenNow'];
        $row['isBestseller'] = (bool)$row['isBestseller'];
        $row['isSpecial'] = (bool)$row['isSpecial'];
        $row['isHalal'] = (bool)$row['isHalal'];
        
        $foods[] = $row;
    }
}

echo json_encode($foods, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
$conn->close();
?>
