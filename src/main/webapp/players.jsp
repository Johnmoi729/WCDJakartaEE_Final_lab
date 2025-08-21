<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.bson.Document" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Player Evaluation System</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- DataTables CSS -->
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css">
    
    <style>
        :root {
            --primary-color: #3498db;
            --secondary-color: #2c3e50;
            --accent-color: #e74c3c;
            --light-color: #ecf0f1;
            --dark-color: #2c3e50;
        }
        
        body {
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .navbar {
            background-color: var(--secondary-color);
        }
        
        .sidebar {
            background-color: var(--dark-color);
            color: white;
            height: calc(100vh - 56px);
            position: sticky;
            top: 56px;
        }
        
        .sidebar .nav-link {
            color: rgba(255, 255, 255, 0.8);
            padding: 0.8rem 1rem;
        }
        
        .sidebar .nav-link:hover {
            color: white;
            background-color: rgba(255, 255, 255, 0.1);
        }
        
        .sidebar .nav-link.active {
            color: white;
            background-color: var(--primary-color);
        }
        
        .card {
            border: none;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease;
        }
        
        .card:hover {
            transform: translateY(-5px);
        }
        
        .stats-card {
            text-align: center;
            padding: 1.5rem;
        }
        
        .stats-card i {
            font-size: 2.5rem;
            margin-bottom: 1rem;
            color: var(--primary-color);
        }
        
        .stats-card h3 {
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }
        
        .stats-card p {
            color: #6c757d;
            margin-bottom: 0;
        }
        
        .player-table {
            background-color: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        
        .table thead th {
            background-color: var(--primary-color);
            color: white;
            border: none;
        }
        
        .btn-primary {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }
        
        .btn-primary:hover {
            background-color: #2980b9;
            border-color: #2980b9;
        }
        
        .btn-action {
            padding: 0.25rem 0.5rem;
            margin: 0 0.1rem;
        }
        
        .value-badge {
            font-weight: bold;
            padding: 0.35em 0.65em;
            border-radius: 50rem;
        }
        
        .pagination .page-item.active .page-link {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }
        
        .section-title {
            border-left: 4px solid var(--primary-color);
            padding-left: 1rem;
            margin-bottom: 1.5rem;
        }
        
        /* Custom DataTables styling */
        .dataTables_filter input {
            border-radius: 20px;
            padding: 0.375rem 0.75rem;
            border: 1px solid #ced4da;
        }
        
        .dataTables_length select {
            border-radius: 20px;
            padding: 0.375rem 1.75rem 0.375rem 0.75rem;
        }
    </style>
</head>
<body>
    <!-- Navigation Bar -->
    <nav class="navbar navbar-expand-lg navbar-dark">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">
                <i class="fas fa-futbol me-2"></i>
                Player Evaluation System
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="#"><i class="fas fa-user me-1"></i> Admin</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#"><i class="fas fa-cog me-1"></i> Settings</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#"><i class="fas fa-sign-out-alt me-1"></i> Logout</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-3 col-lg-2 sidebar d-md-block">
                <div class="position-sticky pt-3">
                    <ul class="nav flex-column">
                        <li class="nav-item">
                            <a class="nav-link active" href="#">
                                <i class="fas fa-home me-2"></i>
                                Dashboard
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#">
                                <i class="fas fa-users me-2"></i>
                                Players
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#">
                                <i class="fas fa-chart-line me-2"></i>
                                Analytics
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#">
                                <i class="fas fa-cog me-2"></i>
                                Settings
                            </a>
                        </li>
                    </ul>
                </div>
            </div>

            <!-- Main Content -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
                <!-- Page Header -->
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h4 class="section-title">Player Evaluation Dashboard</h4>
                    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addPlayerModal">
                        <i class="fas fa-plus me-1"></i> Add New Player
                    </button>
                </div>

                <!-- Stats Cards -->
                <div class="row mb-4">
                    <div class="col-md-3">
                        <div class="card stats-card">
                            <i class="fas fa-users"></i>
                            <h3>24</h3>
                            <p>Total Players</p>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card stats-card">
                            <i class="fas fa-chart-bar"></i>
                            <h3>86%</h3>
                            <p>Average Score</p>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card stats-card">
                            <i class="fas fa-trophy"></i>
                            <h3>9.2</h3>
                            <p>Top Performance</p>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card stats-card">
                            <i class="fas fa-star"></i>
                            <h3>14</h3>
                            <p>Elite Players</p>
                        </div>
                    </div>
                </div>

                <!-- Player Table -->
                <div class="card player-table">
                    <div class="card-body">
                        <div class="table-responsive">
                            <table id="playersTable" class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Player Name</th>
                                        <th>Age</th>
                                        <th>Index Name</th>
                                        <th>Value</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% 
                                    List<Document> players = (List<Document>) request.getAttribute("players");
                                    if (players != null) {
                                        for (Document player : players) {
                                            double value = player.getDouble("value");
                                            String badgeClass = "bg-primary";
                                            if (value < 50) badgeClass = "bg-danger";
                                            else if (value < 80) badgeClass = "bg-warning";
                                            else if (value >= 90) badgeClass = "bg-success";
                                    %>
                                    <tr>
                                        <td><%= player.getObjectId("_id").toString() %></td>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <img src="https://via.placeholder.com/40" class="rounded-circle me-2" alt="Player">
                                                <div>
                                                    <div class="fw-bold"><%= player.get("player_name") %></div>
                                                    <small class="text-muted">ID: <%= player.get("player_id").toString() %></small>
                                                </div>
                                            </div>
                                        </td>
                                        <td><%= player.get("player_age") %></td>
                                        <td><%= player.get("index_name") %></td>
                                        <td>
                                            <span class="value-badge <%= badgeClass %>">
                                                <%= String.format("%.1f", value) %>
                                            </span>
                                        </td>
                                        <td>
                                            <% if (value >= 90) { %>
                                                <span class="badge bg-success">Elite</span>
                                            <% } else if (value >= 70) { %>
                                                <span class="badge bg-primary">Good</span>
                                            <% } else if (value >= 50) { %>
                                                <span class="badge bg-warning">Average</span>
                                            <% } else { %>
                                                <span class="badge bg-danger">Poor</span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <div class="btn-group">
                                                <button class="btn btn-sm btn-outline-primary btn-action" title="Edit">
                                                    <i class="fas fa-edit"></i>
                                                </button>
                                                <button class="btn btn-sm btn-outline-info btn-action" title="View Details">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <button class="btn btn-sm btn-outline-danger btn-action" title="Delete" 
                                                        onclick="return confirm('Are you sure you want to delete this record?')">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                    <% 
                                        }
                                    }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <!-- Add Player Modal -->
    <div class="modal fade" id="addPlayerModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Add New Player Evaluation</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="playerName" class="form-label">Player Name</label>
                                <input type="text" class="form-control" id="playerName" required>
                            </div>
                            <div class="col-md-6">
                                <label for="playerAge" class="form-label">Age</label>
                                <input type="number" class="form-control" id="playerAge" min="16" max="45" required>
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="indexType" class="form-label">Index Type</label>
                                <select class="form-select" id="indexType" required>
                                    <option value="">Select Index Type</option>
                                    <option value="speed">Speed</option>
                                    <option value="strength">Strength</option>
                                    <option value="accurate">Accuracy</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label for="indexValue" class="form-label">Value</label>
                                <input type="range" class="form-range" id="indexValue" min="0" max="100" step="1" oninput="updateValueText(this.value)">
                                <div class="d-flex justify-content-between">
                                    <small>0</small>
                                    <span id="valueText" class="fw-bold">50</span>
                                    <small>100</small>
                                </div>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label for="notes" class="form-label">Evaluation Notes</label>
                            <textarea class="form-control" id="notes" rows="3"></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary">Save Evaluation</button>
                </div>
            </div>
        </div>
    </div>

    <!-- JavaScript Libraries -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js"></script>
    
    <script>
        function updateValueText(value) {
            document.getElementById('valueText').textContent = value;
        }
        
        // Initialize DataTable
        $(document).ready(function() {
            $('#playersTable').DataTable({
                language: {
                    search: "_INPUT_",
                    searchPlaceholder: "Search players...",
                    lengthMenu: "Show _MENU_ entries",
                    info: "Showing _START_ to _END_ of _TOTAL_ entries",
                    paginate: {
                        previous: "<i class='fas fa-chevron-left'></i>",
                        next: "<i class='fas fa-chevron-right'></i>"
                    }
                },
                dom: '<"row"<"col-md-6"l><"col-md-6"f>>rt<"row"<"col-md-6"i><"col-md-6"p>>',
                pageLength: 10,
                responsive: true,
                order: [[1, 'asc']],
                columnDefs: [
                    { orderable: false, targets: [6] } // Disable sorting on actions column
                ]
            });
        });
    </script>
</body>
</html>