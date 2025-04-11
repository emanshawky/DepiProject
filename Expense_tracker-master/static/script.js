fetch("/data")
    .then(response => response.json())
    .then(data => {
        const labels = data.map(item => item[0]);
        const values = data.map(item => item[1]);

        const ctx = document.getElementById("expenseChart").getContext("2d");
        new Chart(ctx, {
            type: "pie",
            data: {
                labels: labels,
                datasets: [{
                    data: values,
                    backgroundColor: ["#ff6384", "#36a2eb", "#cc65fe", "#ffce56", "#2ecc71"],
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: "bottom",
                    },
                },
            },
        });
    })
    .catch(error => console.error("Error fetching data:", error));
