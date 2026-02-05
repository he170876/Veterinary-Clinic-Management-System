<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<html>
    <head>
        <title>Service Details</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/anipat-master/css/bootstrap.min.css">
    </head>
    <body>
        <div class="container mt-5">
            <h1>Service Details</h1>
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">${service.name}</h5>
                    <p class="card-text">
                        <strong>ID:</strong> ${service.serviceId}<br>
                        <strong>Category:</strong> ${service.category}<br>
                        <strong>Duration:</strong> ${service.duration} minutes<br>
                        <strong>Price:</strong> <fmt:formatNumber value="${service.price}" type="currency" currencySymbol="$"/><br>
                        <strong>Description:</strong> ${service.description}
                    </p>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/owner/services" class="btn btn-secondary">Back to List</a>
        </div>
    </body>
</html>