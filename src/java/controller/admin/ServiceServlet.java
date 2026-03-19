package controller.admin;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Service;
import service.ServiceService;
import service.impl.ServiceServiceImpl;

/**
 * Servlet handling CRUD operations for Services.
 */
@WebServlet(name = "ServiceServlet", urlPatterns = {"/owner/services/*"})
public class ServiceServlet extends HttpServlet {

    private ServiceService serviceService;

    @Override
    public void init() throws ServletException {
        this.serviceService = new ServiceServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            listServices(request, response);
        } else {
            try {
                int id = Integer.parseInt(pathInfo.substring(1));
                getServiceById(request, response, id);
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid service ID");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("create".equals(action)) {
            createService(request, response);
        } else if ("update".equals(action)) {
            updateService(request, response);
        } else if ("delete".equals(action)) {
            deleteService(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }

    private void listServices(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Service> allServices = serviceService.getAllServices();
        int pageSize = 7;
        int totalServices = allServices.size();
        int totalPages = (int) Math.ceil((double) totalServices / pageSize);
        int currentPage = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try {
                currentPage = Integer.parseInt(pageParam);
            } catch (NumberFormatException ignored) {}
        }
        if (currentPage < 1) currentPage = 1;
        if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;
        int fromIndex = (currentPage - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalServices);
        List<Service> services = (fromIndex < toIndex) ? allServices.subList(fromIndex, toIndex) : java.util.Collections.emptyList();
        request.setAttribute("services", services);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalServices", totalServices);
        request.setAttribute("pageSize", pageSize);
        request.getRequestDispatcher("/WEB-INF/views/admin/services.jsp").forward(request, response);
    }

    private void getServiceById(HttpServletRequest request, HttpServletResponse response, int id)
            throws ServletException, IOException {
        Service service = serviceService.getServiceById(id).orElse(null);
        if (service != null) {
            request.setAttribute("service", service);
            request.getRequestDispatcher("/WEB-INF/views/admin/services/detail.jsp").forward(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Service not found");
        }
    }

    private void createService(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            String name = request.getParameter("name");
            String category = request.getParameter("category");
            String description = request.getParameter("description");
            String durationStr = request.getParameter("duration");
            String priceStr = request.getParameter("price");

            // ====== VALIDATION ======
            if (name == null || name.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Service name is required.");
                return;
            }
            name = name.trim();
            if (name.length() > 100) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Service name must be less than 100 characters.");
                return;
            }

            if (serviceService.existsByName(name)) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                response.setContentType("text/plain;charset=UTF-8");
                response.getWriter().write("Service name already exists");
                return;
            }

            int duration = 0;
            try {
                if (durationStr != null && !durationStr.trim().isEmpty()) {
                    duration = Integer.parseInt(durationStr.trim());
                    if (duration < 0) {
                        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Duration cannot be negative.");
                        return;
                    }
                }
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid duration format. Please enter a whole number.");
                return;
            }

            double price = 0.0;
            try {
                if (priceStr != null && !priceStr.trim().isEmpty()) {
                    price = Double.parseDouble(priceStr.trim());
                    if (price < 0) {
                        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Price cannot be negative.");
                        return;
                    }
                }
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid price format. Please enter a number.");
                return;
            }

            if (description != null && description.length() > 500) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Description must be less than 500 characters.");
                return;
            }

            Service service = new Service();
            service.setName(name);
            service.setCategory(category != null ? category.trim() : "");
            service.setDescription(description != null ? description.trim() : "");
            service.setDuration(duration);
            service.setPrice(price);

            Service created = serviceService.createService(service);
            if (created != null) {
                response.sendRedirect(request.getContextPath() + "/owner/services");
            } else {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to create service");
            }
        } catch (Exception e) {
            System.err.println("CreateService ERROR: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An unexpected error occurred.");
        }
    }

    private void updateService(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            String idStr = request.getParameter("serviceId");
            if (idStr == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Service ID required");
                return;
            }
            
            int id = Integer.parseInt(idStr);
            Service service = serviceService.getServiceById(id).orElse(null);
            if (service == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Service not found");
                return;
            }
            
            String name = request.getParameter("name");
            String category = request.getParameter("category");
            String description = request.getParameter("description");
            String durationStr = request.getParameter("duration");
            String priceStr = request.getParameter("price");

            // ====== VALIDATION ======
            if (name == null || name.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Service name is required.");
                return;
            }
            if (name.trim().length() > 100) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Service name must be less than 100 characters.");
                return;
            }

            int duration = 0;
            try {
                if (durationStr != null && !durationStr.trim().isEmpty()) {
                    duration = Integer.parseInt(durationStr.trim());
                    if (duration < 0) {
                        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Duration cannot be negative.");
                        return;
                    }
                }
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid duration format. Please enter a whole number.");
                return;
            }

            double price = 0.0;
            try {
                if (priceStr != null && !priceStr.trim().isEmpty()) {
                    price = Double.parseDouble(priceStr.trim());
                    if (price < 0) {
                        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Price cannot be negative.");
                        return;
                    }
                }
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid price format. Please enter a number.");
                return;
            }

            if (description != null && description.length() > 500) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Description must be less than 500 characters.");
                return;
            }

            service.setName(name.trim());
            service.setCategory(category != null ? category.trim() : "");
            service.setDescription(description != null ? description.trim() : "");
            service.setDuration(duration);
            service.setPrice(price);

            if (serviceService.updateService(service)) {
                response.sendRedirect(request.getContextPath() + "/owner/services");
            } else {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to update service");
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid ID format");
        } catch (Exception e) {
            System.err.println("UpdateService ERROR: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }

    private void deleteService(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            String idStr = request.getParameter("serviceId");
            if (idStr == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Service ID required");
                return;
            }
            
            int id = Integer.parseInt(idStr);
            if (serviceService.deleteService(id)) {
                response.sendRedirect(request.getContextPath() + "/owner/services");
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Service not found or already deleted");
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid ID format");
        } catch (Exception e) {
            System.err.println("DeleteService ERROR: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }
}
