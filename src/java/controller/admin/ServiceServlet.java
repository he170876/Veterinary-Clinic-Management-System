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
        // Check authentication
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            // List all services
            listServices(request, response);
        } else {
            // Get service by id
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
        // Check authentication
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
        List<Service> services = serviceService.getAllServices();
        request.setAttribute("services", services);
        request.getRequestDispatcher("/WEB-INF/views/admin/services/list.jsp").forward(request, response);
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
        Service service = new Service();
        service.setName(request.getParameter("name"));
        service.setCategory(request.getParameter("category"));
        String durationStr = request.getParameter("duration");
        if (durationStr != null) {
            try {
                service.setDuration(Integer.parseInt(durationStr));
            } catch (NumberFormatException e) {
                service.setDuration(0);
            }
        }
        String priceStr = request.getParameter("price");
        if (priceStr != null) {
            try {
                service.setPrice(Double.parseDouble(priceStr));
            } catch (NumberFormatException e) {
                service.setPrice(0.0);
            }
        }
        service.setDescription(request.getParameter("description"));

        Service created = serviceService.createService(service);
        if (created != null) {
            response.sendRedirect(request.getContextPath() + "/owner/services");
        } else {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to create service");
        }
    }

    private void updateService(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idStr = request.getParameter("serviceId");
        if (idStr == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Service ID required");
            return;
        }
        try {
            int id = Integer.parseInt(idStr);
            Service service = serviceService.getServiceById(id).orElse(null);
            if (service == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Service not found");
                return;
            }

            service.setName(request.getParameter("name"));
            service.setCategory(request.getParameter("category"));
            String durationStr = request.getParameter("duration");
            if (durationStr != null) {
                try {
                    service.setDuration(Integer.parseInt(durationStr));
                } catch (NumberFormatException e) {
                    service.setDuration(0);
                }
            }
            String priceStr = request.getParameter("price");
            if (priceStr != null) {
                try {
                    service.setPrice(Double.parseDouble(priceStr));
                } catch (NumberFormatException e) {
                    service.setPrice(0.0);
                }
            }
            service.setDescription(request.getParameter("description"));

            if (serviceService.updateService(service)) {
                response.sendRedirect(request.getContextPath() + "/owner/services");
            } else {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to update service");
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid service ID");
        }
    }

    private void deleteService(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idStr = request.getParameter("serviceId");
        if (idStr == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Service ID required");
            return;
        }
        try {
            int id = Integer.parseInt(idStr);
            if (serviceService.deleteService(id)) {
                response.sendRedirect(request.getContextPath() + "/owner/services");
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Service not found or failed to delete");
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid service ID");
        }
    }
}