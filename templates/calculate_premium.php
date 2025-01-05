<?php
// Database connection
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "sma";

$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Fetch user information and insurance policies
$sql = "SELECT u.UserID, u.Name, u.Age, u.SmokerStatus, u.PreExistingCondition, u.BMI, 
        p.PolicyID, p.PolicyName, c.CompanyName, p.BasePremiumRate, p.SmokerSurchargeRate, 
        p.PreExistingRate, p.BMIImpactRate, p.AdminFee, p.TaxRate 
        FROM Users u 
        CROSS JOIN HealthInsurancePolicies p 
        JOIN Companies c ON p.CompanyID = c.CompanyID
        WHERE u.Age BETWEEN p.MinAge AND p.MaxAge";

$result = $conn->query($sql);

// Check if data exists
if ($result->num_rows > 0) {
    echo "<h1>Insurance Quotes</h1>";
    echo "<table border='1'>
            <tr>
                <th>Company Name</th>
                <th>Policy Name</th>
                <th>Quote Amount</th>
                <th>Insights</th>
            </tr>";

    while ($row = $result->fetch_assoc()) {
        // Premium calculation logic
        $basePremium = $row['BasePremiumRate'];
        $smokerSurcharge = $row['SmokerStatus'] * $row['SmokerSurchargeRate'] * $basePremium;
        $preExistingSurcharge = $row['PreExistingCondition'] * $row['PreExistingRate'] * $basePremium;
        $bmiImpact = ($row['BMI'] - 25) * $row['BMIImpactRate'] * $basePremium;
        $adminFee = $row['AdminFee'];
        $taxRate = $row['TaxRate'];

        $totalPremium = round(($basePremium + $smokerSurcharge + $preExistingSurcharge + $bmiImpact + $adminFee) * (1 + $taxRate / 100), 2);

        // Insights
        $exerciseImpact = 0;
        $smokingImpact = 0;
        $exerciseSavings = 0;
        $smokingSavings = 0;

        // If the user doesn't smoke, they can save on premiums
        if ($row['SmokerStatus'] == 1) {
            // Smoking savings (reducing smoker surcharge)
            $smokingSavings = round($smokerSurcharge, 2);
            $smokerSurcharge = 0; // removing smoker surcharge
        }

        // If the BMI is above 25, advise to exercise
        if ($row['BMI'] > 25) {
            // Exercise impact (improving BMI and reducing premium)
            $exerciseImpact = round($bmiImpact * 0.5, 2); // assume exercise reduces BMI-related surcharge by half
            $exerciseSavings = round($exerciseImpact, 2);
            $bmiImpact -= $exerciseImpact; // reducing BMI impact
        }

        $newTotalPremium = round(($basePremium + $smokerSurcharge + $preExistingSurcharge + $bmiImpact + $adminFee) * (1 + $taxRate / 100), 2);

        // Displaying the quote information and insights
        echo "<tr>
                <td>{$row['CompanyName']}</td>
                <td>{$row['PolicyName']}</td>
                <td>{$totalPremium}</td>
                <td>
                    <ul>
                        <li><strong>Exercise Insight:</strong> If you exercise 3 times a week, your premium could be reduced by ₹{$exerciseSavings}.</li>
                        <li><strong>Smoking Insight:</strong> If you quit smoking, you can save ₹{$smokingSavings} on your premium.</li>
                        <li><strong>New Premium After Adjustments:</strong> ₹{$newTotalPremium}</li>
                    </ul>
                </td>
              </tr>";
    }
    echo "</table>";
} else {
    echo "No eligible users or policies found.";
}

$conn->close();
?>
