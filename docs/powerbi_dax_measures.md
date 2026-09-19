# Power BI DAX Measures

These are the core measures used in the dashboard.

```DAX
Total Spend =
SUM(Fact_Procurement[Actual_Total_AZN])
```

```DAX
Estimated Spend =
SUM(Fact_Procurement[Estimated_Total_AZN])
```

```DAX
Total Savings =
SUM(Fact_Procurement[Savings_AZN])
```

```DAX
Savings % =
DIVIDE(
    [Total Savings],
    [Estimated Spend]
)
```

```DAX
Procurement Count =
DISTINCTCOUNT(Fact_Procurement[Procurement_ID])
```

```DAX
Active Supplier Count =
CALCULATE(
    DISTINCTCOUNT(Fact_Procurement[Supplier_ID]),
    Fact_Procurement[Supplier_ID] <> "SUP-UNKNOWN"
)
```

```DAX
Comparable Actual Spend =
CALCULATE(
    [Total Spend],
    Fact_Procurement[Estimate_Data_Status] = "Available"
)
```

```DAX
Estimate Coverage % =
DIVIDE(
    CALCULATE(
        [Procurement Count],
        Fact_Procurement[Estimate_Data_Status] = "Available"
    ),
    [Procurement Count]
)
```

```DAX
Completed Procurements =
CALCULATE(
    [Procurement Count],
    Fact_Procurement[Status] = "Completed"
)
```

```DAX
On Time Deliveries =
CALCULATE(
    [Procurement Count],
    Fact_Procurement[Delivery_Status] = "On Time"
)
```

```DAX
On Time Delivery % =
DIVIDE(
    [On Time Deliveries],
    CALCULATE(
        [Procurement Count],
        Fact_Procurement[Delivery_Status] IN {"On Time", "Late"}
    )
)
```

```DAX
Average Quality Score =
AVERAGE(Fact_Procurement[Quality_Score])
```

```DAX
Late Deliveries =
CALCULATE(
    [Procurement Count],
    Fact_Procurement[Delivery_Status] = "Late"
)
```

```DAX
Late Delivery % =
DIVIDE(
    [Late Deliveries],
    [On Time Deliveries] + [Late Deliveries]
)
```

```DAX
Average Delivery Delay Days =
CALCULATE(
    AVERAGE(Fact_Procurement[Delivery_Delay_Days]),
    Fact_Procurement[Delivery_Status] = "Late"
)
```

```DAX
Overspend Amount =
CALCULATE(
    -[Total Savings],
    Fact_Procurement[Savings_AZN] < 0
)
```

```DAX
Savings Transactions =
CALCULATE(
    [Procurement Count],
    Fact_Procurement[Savings_AZN] > 0
)
```

```DAX
Overspend Transactions =
CALCULATE(
    [Procurement Count],
    Fact_Procurement[Savings_AZN] < 0
)
```

```DAX
Savings Transaction % =
DIVIDE(
    [Savings Transactions],
    CALCULATE(
        [Procurement Count],
        Fact_Procurement[Estimate_Data_Status] = "Available"
    )
)
```

```DAX
Missing Supplier Transactions =
CALCULATE(
    [Procurement Count],
    Fact_Procurement[Supplier_Data_Status] = "Missing Supplier"
)
```

```DAX
Missing Estimate Transactions =
CALCULATE(
    [Procurement Count],
    Fact_Procurement[Estimate_Data_Status] = "Missing Estimate"
)
```

```DAX
Missing Delivery Date =
CALCULATE(
    [Procurement Count],
    Fact_Procurement[Delivery_Status] = "Missing Delivery Date"
)
```

```DAX
Missing Quality Score =
CALCULATE(
    [Procurement Count],
    FILTER(
        Fact_Procurement,
        Fact_Procurement[Status] = "Completed"
            && ISBLANK(Fact_Procurement[Quality_Score])
    )
)
```

```DAX
High Risk Supplier Spend =
CALCULATE(
    [Total Spend],
    Dim_Supplier[Risk_Level] = "High"
)
```
