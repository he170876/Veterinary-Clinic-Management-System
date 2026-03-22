USE [master]
GO
IF DB_ID(N'VetClinicManagement1') IS NOT NULL
BEGIN
    ALTER DATABASE [VetClinicManagement1] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [VetClinicManagement1];
END
GO
USE [master]
GO
-- Create database using default data path (avoids "Access is denied" in Program Files).
-- If VetClinicManagement1 already exists, skip creation.
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'VetClinicManagement1')
BEGIN
    CREATE DATABASE [VetClinicManagement1]
END
GO
ALTER DATABASE [VetClinicManagement1] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [VetClinicManagement1].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [VetClinicManagement1] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [VetClinicManagement1] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [VetClinicManagement1] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [VetClinicManagement1] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [VetClinicManagement1] SET ARITHABORT OFF 
GO
ALTER DATABASE [VetClinicManagement1] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [VetClinicManagement1] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [VetClinicManagement1] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [VetClinicManagement1] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [VetClinicManagement1] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [VetClinicManagement1] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [VetClinicManagement1] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [VetClinicManagement1] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [VetClinicManagement1] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [VetClinicManagement1] SET  ENABLE_BROKER 
GO
ALTER DATABASE [VetClinicManagement1] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [VetClinicManagement1] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [VetClinicManagement1] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [VetClinicManagement1] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [VetClinicManagement1] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [VetClinicManagement1] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [VetClinicManagement1] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [VetClinicManagement1] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [VetClinicManagement1] SET  MULTI_USER 
GO
ALTER DATABASE [VetClinicManagement1] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [VetClinicManagement1] SET DB_CHAINING OFF 
GO
ALTER DATABASE [VetClinicManagement1] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [VetClinicManagement1] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [VetClinicManagement1] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [VetClinicManagement1] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [VetClinicManagement1] SET QUERY_STORE = ON
GO
ALTER DATABASE [VetClinicManagement1] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [VetClinicManagement1]
GO
/****** Object:  Table [dbo].[Appointments]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Appointments](
	[appointment_id] [int] IDENTITY(1,1) NOT NULL,
	[pet_id] [int] NOT NULL,
	[customer_id] [int] NOT NULL,
	[veterinarian_id] [int] NULL,
	[appointment_time] [datetime] NOT NULL,
	[status] [nvarchar](30) NULL,
	[created_at] [datetime] NULL,
	[service_id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[appointment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Blogs]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Blogs](
	[blog_id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](200) NULL,
	[content] [nvarchar](max) NULL,
	[created_at] [datetime] NULL,
	[status] [nvarchar](20) NOT NULL,
	[author_user_id] [int] NULL,
	[updated_at] [datetime] NULL,
	[thumbnail_url] [nvarchar](255) NULL,
	[slug] [nvarchar](150) NULL,
	[category] [nvarchar](100) NULL,
	[meta_description] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[blog_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customers]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customers](
	[customer_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Images]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Images](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](255) NULL,
	[url] [nvarchar](max) NOT NULL,
	[alt_text] [nvarchar](255) NULL,
	[section] [nvarchar](50) NULL,
	[sort_order] [int] NOT NULL,
	[created_at] [datetime] NOT NULL,
 CONSTRAINT [PK_Images] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceItems]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceItems](
	[item_id] [int] IDENTITY(1,1) NOT NULL,
	[invoice_id] [int] NOT NULL,
	[item_type] [nvarchar](20) NULL,
	[ref_id] [int] NULL,
	[name_snapshot] [nvarchar](255) NULL,
	[unit_price] [decimal](12, 2) NULL,
	[quantity] [int] NULL,
	[total_price] [decimal](12, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[item_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Invoices]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Invoices](
	[invoice_id] [int] IDENTITY(1,1) NOT NULL,
	[visit_id] [int] NOT NULL,
	[total_amount] [decimal](12, 2) NULL,
	[status] [nvarchar](20) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[invoice_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LabStaff]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LabStaff](
	[staff_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[position] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[staff_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LabTestRequests]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LabTestRequests](
	[request_id] [int] IDENTITY(1,1) NOT NULL,
	[visit_id] [int] NOT NULL,
	[test_id] [int] NOT NULL,
	[veterinarian_id] [int] NOT NULL,
	[request_time] [datetime] NULL,
	[status] [nvarchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[request_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LabTestResults]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LabTestResults](
	[result_id] [int] IDENTITY(1,1) NOT NULL,
	[request_id] [int] NOT NULL,
	[result_value] [nvarchar](255) NULL,
	[result_note] [nvarchar](500) NULL,
	[result_file] [nvarchar](255) NULL,
	[result_date] [datetime] NULL,
	[lab_staff_id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[result_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[request_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LabTests]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LabTests](
	[test_id] [int] IDENTITY(1,1) NOT NULL,
	[test_name] [nvarchar](255) NULL,
	[description] [nvarchar](255) NULL,
	[normal_range] [nvarchar](100) NULL,
	[unit] [nvarchar](50) NULL,
	[status] [nvarchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[test_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MedicalRecords]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MedicalRecords](
	[record_id] [int] IDENTITY(1,1) NOT NULL,
	[visit_id] [int] NOT NULL,
	[veterinarian_id] [int] NOT NULL,
	[diagnosis] [nvarchar](500) NULL,
	[treatment] [nvarchar](500) NULL,
	[note] [nvarchar](500) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[record_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MedicalRecordServices]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MedicalRecordServices](
	[record_service_id] [int] IDENTITY(1,1) NOT NULL,
	[record_id] [int] NOT NULL,
	[service_id] [int] NOT NULL,
	[quantity] [int] NULL,
	[price] [decimal](10, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[record_service_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Notifications]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notifications](
	[notification_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[title] [nvarchar](100) NULL,
	[message] [nvarchar](255) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[notification_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PasswordResetTokens]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PasswordResetTokens](
	[token] [nvarchar](64) NOT NULL,
	[email] [nvarchar](255) NOT NULL,
	[expires_at] [datetime2](7) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[token] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Pets]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Pets](
	[pet_id] [int] IDENTITY(1,1) NOT NULL,
	[customer_id] [int] NOT NULL,
	[name] [nvarchar](50) NULL,
	[species] [nvarchar](50) NULL,
	[breed] [nvarchar](100) NULL,
	[gender] [nvarchar](10) NULL,
	[birth_date] [date] NULL,
	[weight] [decimal](10, 2) NULL,
	[created_at] [datetime] NULL,
	[photoUrl] [nvarchar](500) NULL,
	[isDeleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[pet_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Prescriptions]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Prescriptions](
	[prescription_id] [int] IDENTITY(1,1) NOT NULL,
	[record_id] [int] NOT NULL,
	[medicine_name] [nvarchar](100) NULL,
	[dosage] [nvarchar](100) NULL,
	[duration] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[prescription_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Receptionists]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Receptionists](
	[receptionist_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[receptionist_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Roles]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[role_id] [int] IDENTITY(1,1) NOT NULL,
	[role_name] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[role_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Services]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Services](
	[service_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NULL,
	[price] [decimal](10, 2) NULL,
	[description] [nvarchar](255) NULL,
	[category] [nvarchar](100) NULL,
	[duration] [int] NULL,
	[is_deleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[service_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[user_id] [int] IDENTITY(1,1) NOT NULL,
	[email] [nvarchar](100) NOT NULL,
	[password] [nvarchar](100) NOT NULL,
	[role_id] [int] NOT NULL,
	[status] [nvarchar](50) NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
	[full_name] [nvarchar](100) NULL,
	[phone] [nvarchar](20) NULL,
	[address] [nvarchar](255) NULL,
	[isDeleted] [bit] NOT NULL,
	[profile_picture_url] [nvarchar](500) NULL,
	[is_google_user] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Veterinarians]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Veterinarians](
	[veterinarian_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[specialization] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[veterinarian_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Visits]    Script Date: 26/02/2026 22:58:24  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Visits](
	[visit_id] [int] IDENTITY(1,1) NOT NULL,
	[appointment_id] [int] NULL,
	[pet_id] [int] NOT NULL,
	[customer_id] [int] NOT NULL,
	[check_in_time] [datetime] NULL,
	[check_out_time] [datetime] NULL,
	[visit_status] [nvarchar](30) NULL,
	[staff_id] [int] NULL,
	[veterinarian_id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[visit_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PasswordResetTokens_email]    Script Date: 26/02/2026 22:58:25  ******/
CREATE NONCLUSTERED INDEX [IX_PasswordResetTokens_email] ON [dbo].[PasswordResetTokens]
(
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_PasswordResetTokens_expires_at]    Script Date: 26/02/2026 22:58:25  ******/
CREATE NONCLUSTERED INDEX [IX_PasswordResetTokens_expires_at] ON [dbo].[PasswordResetTokens]
(
	[expires_at] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Users_Email]    Script Date: 26/02/2026 22:58:25  ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Users_Email] ON [dbo].[Users]
(
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Appointments] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Blogs] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Blogs] ADD  DEFAULT ('Draft') FOR [status]
GO
ALTER TABLE [dbo].[Images] ADD  DEFAULT ((0)) FOR [sort_order]
GO
ALTER TABLE [dbo].[Images] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Invoices] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[LabTestRequests] ADD  DEFAULT (getdate()) FOR [request_time]
GO
ALTER TABLE [dbo].[LabTestResults] ADD  DEFAULT (getdate()) FOR [result_date]
GO
ALTER TABLE [dbo].[MedicalRecords] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Notifications] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[PasswordResetTokens] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[Pets] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Pets] ADD  DEFAULT ((0)) FOR [isDeleted]
GO
ALTER TABLE [dbo].[Services] ADD  DEFAULT ((0)) FOR [is_deleted]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ((0)) FOR [isDeleted]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ((0)) FOR [is_google_user]
GO
ALTER TABLE [dbo].[Appointments]  WITH CHECK ADD  CONSTRAINT [FK_Appointments_Customers] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([customer_id])
GO
ALTER TABLE [dbo].[Appointments] CHECK CONSTRAINT [FK_Appointments_Customers]
GO
ALTER TABLE [dbo].[Appointments]  WITH CHECK ADD  CONSTRAINT [FK_Appointments_Pets] FOREIGN KEY([pet_id])
REFERENCES [dbo].[Pets] ([pet_id])
GO
ALTER TABLE [dbo].[Appointments] CHECK CONSTRAINT [FK_Appointments_Pets]
GO
ALTER TABLE [dbo].[Appointments]  WITH CHECK ADD  CONSTRAINT [fk_appointments_service] FOREIGN KEY([service_id])
REFERENCES [dbo].[Services] ([service_id])
GO
ALTER TABLE [dbo].[Appointments] CHECK CONSTRAINT [fk_appointments_service]
GO
ALTER TABLE [dbo].[Appointments]  WITH CHECK ADD  CONSTRAINT [FK_Appointments_Vets] FOREIGN KEY([veterinarian_id])
REFERENCES [dbo].[Veterinarians] ([veterinarian_id])
GO
ALTER TABLE [dbo].[Appointments] CHECK CONSTRAINT [FK_Appointments_Vets]
GO
ALTER TABLE [dbo].[Blogs]  WITH CHECK ADD  CONSTRAINT [FK_Blogs_Users] FOREIGN KEY([author_user_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Blogs] CHECK CONSTRAINT [FK_Blogs_Users]
GO
ALTER TABLE [dbo].[Customers]  WITH CHECK ADD  CONSTRAINT [FK_Customers_Users] FOREIGN KEY([user_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Customers] CHECK CONSTRAINT [FK_Customers_Users]
GO
ALTER TABLE [dbo].[InvoiceItems]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceItems_Invoices] FOREIGN KEY([invoice_id])
REFERENCES [dbo].[Invoices] ([invoice_id])
GO
ALTER TABLE [dbo].[InvoiceItems] CHECK CONSTRAINT [FK_InvoiceItems_Invoices]
GO
ALTER TABLE [dbo].[Invoices]  WITH CHECK ADD  CONSTRAINT [FK_Invoices_Visits] FOREIGN KEY([visit_id])
REFERENCES [dbo].[Visits] ([visit_id])
GO
ALTER TABLE [dbo].[Invoices] CHECK CONSTRAINT [FK_Invoices_Visits]
GO
ALTER TABLE [dbo].[LabStaff]  WITH CHECK ADD  CONSTRAINT [FK_LabStaff_Users] FOREIGN KEY([user_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[LabStaff] CHECK CONSTRAINT [FK_LabStaff_Users]
GO
ALTER TABLE [dbo].[LabTestRequests]  WITH CHECK ADD  CONSTRAINT [FK_LabReq_Test] FOREIGN KEY([test_id])
REFERENCES [dbo].[LabTests] ([test_id])
GO
ALTER TABLE [dbo].[LabTestRequests] CHECK CONSTRAINT [FK_LabReq_Test]
GO
ALTER TABLE [dbo].[LabTestRequests]  WITH CHECK ADD  CONSTRAINT [FK_LabReq_Vet] FOREIGN KEY([veterinarian_id])
REFERENCES [dbo].[Veterinarians] ([veterinarian_id])
GO
ALTER TABLE [dbo].[LabTestRequests] CHECK CONSTRAINT [FK_LabReq_Vet]
GO
ALTER TABLE [dbo].[LabTestRequests]  WITH CHECK ADD  CONSTRAINT [FK_LabReq_Visit] FOREIGN KEY([visit_id])
REFERENCES [dbo].[Visits] ([visit_id])
GO
ALTER TABLE [dbo].[LabTestRequests] CHECK CONSTRAINT [FK_LabReq_Visit]
GO
ALTER TABLE [dbo].[LabTestResults]  WITH CHECK ADD  CONSTRAINT [FK_LabResult_Request] FOREIGN KEY([request_id])
REFERENCES [dbo].[LabTestRequests] ([request_id])
GO
ALTER TABLE [dbo].[LabTestResults] CHECK CONSTRAINT [FK_LabResult_Request]
GO
ALTER TABLE [dbo].[LabTestResults]  WITH CHECK ADD  CONSTRAINT [FK_LabResult_Staff] FOREIGN KEY([lab_staff_id])
REFERENCES [dbo].[LabStaff] ([staff_id])
GO
ALTER TABLE [dbo].[LabTestResults] CHECK CONSTRAINT [FK_LabResult_Staff]
GO
ALTER TABLE [dbo].[MedicalRecords]  WITH CHECK ADD  CONSTRAINT [FK_MedicalRecords_Vets] FOREIGN KEY([veterinarian_id])
REFERENCES [dbo].[Veterinarians] ([veterinarian_id])
GO
ALTER TABLE [dbo].[MedicalRecords] CHECK CONSTRAINT [FK_MedicalRecords_Vets]
GO
ALTER TABLE [dbo].[MedicalRecords]  WITH CHECK ADD  CONSTRAINT [FK_MedicalRecords_Visits] FOREIGN KEY([visit_id])
REFERENCES [dbo].[Visits] ([visit_id])
GO
ALTER TABLE [dbo].[MedicalRecords] CHECK CONSTRAINT [FK_MedicalRecords_Visits]
GO
ALTER TABLE [dbo].[MedicalRecordServices]  WITH CHECK ADD  CONSTRAINT [FK_MRS_Record] FOREIGN KEY([record_id])
REFERENCES [dbo].[MedicalRecords] ([record_id])
GO
ALTER TABLE [dbo].[MedicalRecordServices] CHECK CONSTRAINT [FK_MRS_Record]
GO
ALTER TABLE [dbo].[MedicalRecordServices]  WITH CHECK ADD  CONSTRAINT [FK_MRS_Service] FOREIGN KEY([service_id])
REFERENCES [dbo].[Services] ([service_id])
GO
ALTER TABLE [dbo].[MedicalRecordServices] CHECK CONSTRAINT [FK_MRS_Service]
GO
ALTER TABLE [dbo].[Notifications]  WITH CHECK ADD  CONSTRAINT [FK_Notifications_Users] FOREIGN KEY([user_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Notifications] CHECK CONSTRAINT [FK_Notifications_Users]
GO
ALTER TABLE [dbo].[Pets]  WITH CHECK ADD  CONSTRAINT [FK_Pets_Customers] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([customer_id])
GO
ALTER TABLE [dbo].[Pets] CHECK CONSTRAINT [FK_Pets_Customers]
GO
ALTER TABLE [dbo].[Prescriptions]  WITH CHECK ADD  CONSTRAINT [FK_Prescriptions_Record] FOREIGN KEY([record_id])
REFERENCES [dbo].[MedicalRecords] ([record_id])
GO
ALTER TABLE [dbo].[Prescriptions] CHECK CONSTRAINT [FK_Prescriptions_Record]
GO
ALTER TABLE [dbo].[Receptionists]  WITH CHECK ADD  CONSTRAINT [FK_Receptionists_Users] FOREIGN KEY([user_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Receptionists] CHECK CONSTRAINT [FK_Receptionists_Users]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_Roles] FOREIGN KEY([role_id])
REFERENCES [dbo].[Roles] ([role_id])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_Roles]
GO
ALTER TABLE [dbo].[Veterinarians]  WITH CHECK ADD  CONSTRAINT [FK_Vets_Users] FOREIGN KEY([user_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[Veterinarians] CHECK CONSTRAINT [FK_Vets_Users]
GO
ALTER TABLE [dbo].[Visits]  WITH CHECK ADD  CONSTRAINT [FK_Visits_Appointments] FOREIGN KEY([appointment_id])
REFERENCES [dbo].[Appointments] ([appointment_id])
GO
ALTER TABLE [dbo].[Visits] CHECK CONSTRAINT [FK_Visits_Appointments]
GO
ALTER TABLE [dbo].[Visits]  WITH CHECK ADD  CONSTRAINT [FK_Visits_Customers] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([customer_id])
GO
ALTER TABLE [dbo].[Visits] CHECK CONSTRAINT [FK_Visits_Customers]
GO
ALTER TABLE [dbo].[Visits]  WITH CHECK ADD  CONSTRAINT [FK_Visits_Pets] FOREIGN KEY([pet_id])
REFERENCES [dbo].[Pets] ([pet_id])
GO
ALTER TABLE [dbo].[Visits] CHECK CONSTRAINT [FK_Visits_Pets]
GO
ALTER TABLE [dbo].[Visits]  WITH CHECK ADD  CONSTRAINT [FK_Visits_Receptionists] FOREIGN KEY([staff_id])
REFERENCES [dbo].[Receptionists] ([receptionist_id])
GO
ALTER TABLE [dbo].[Visits] CHECK CONSTRAINT [FK_Visits_Receptionists]
GO
ALTER TABLE [dbo].[Visits]  WITH CHECK ADD  CONSTRAINT [FK_Visits_Vets] FOREIGN KEY([veterinarian_id])
REFERENCES [dbo].[Veterinarians] ([veterinarian_id])
GO
ALTER TABLE [dbo].[Visits] CHECK CONSTRAINT [FK_Visits_Vets]
GO
USE [master]
GO
ALTER DATABASE [VetClinicManagement1] SET  READ_WRITE 
GO

/* ===============================
   VET CLINIC MANAGEMENT SYSTEM
   SEED DATA (run after schema script)
   =============================== */

USE VetClinicManagement1;
GO

/* ========= ROLES ========= */
INSERT INTO Roles (role_name) VALUES ('Customer');
INSERT INTO Roles (role_name) VALUES ('Veterinarian');
INSERT INTO Roles (role_name) VALUES ('Receptionist');
INSERT INTO Roles (role_name) VALUES ('LabStaff');
INSERT INTO Roles (role_name) VALUES ('Admin');
INSERT INTO Roles (role_name) VALUES ('ClinicOwner');
GO

/* ========= USERS (password dev123 = SHA-256 hex below) ========= */
-- Customer: dev@anipats.com / dev123
INSERT INTO Users (email, password, role_id, status, full_name, phone, address)
VALUES (
    'dev@anipats.com',
    '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b',
    (SELECT role_id FROM Roles WHERE role_name = 'Customer'),
    'Active',
    'Alex Johnson',
    '+1 (555) 100-2001',
    '123 Pet Lane, New York, NY'
);

-- Customer 2
INSERT INTO Users (email, password, role_id, status, full_name, phone, address)
VALUES (
    'mary.wilson@email.com',
    '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b',
    (SELECT role_id FROM Roles WHERE role_name = 'Customer'),
    'Active',
    'Mary Wilson',
    '+1 (555) 100-2002',
    '456 Oak St, Brooklyn, NY'
);

-- Veterinarian 1
INSERT INTO Users (email, password, role_id, status, full_name, phone, address)
VALUES (
    'dr.smith@anipats.com',
    '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b',
    (SELECT role_id FROM Roles WHERE role_name = 'Veterinarian'),
    'Active',
    'Dr. Sarah Smith',
    '+1 (555) 200-3001',
    NULL
);

-- Veterinarian 2
INSERT INTO Users (email, password, role_id, status, full_name, phone, address)
VALUES (
    'dr.james@anipats.com',
    '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b',
    (SELECT role_id FROM Roles WHERE role_name = 'Veterinarian'),
    'Active',
    'Dr. James Lee',
    '+1 (555) 200-3002',
    NULL
);

-- Receptionist
INSERT INTO Users (email, password, role_id, status, full_name, phone, address)
VALUES (
    'reception@anipats.com',
    '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b',
    (SELECT role_id FROM Roles WHERE role_name = 'Receptionist'),
    'Active',
    'Emma Davis',
    '+1 (555) 300-4001',
    NULL
);

-- Lab staff
INSERT INTO Users (email, password, role_id, status, full_name, phone, address)
VALUES (
    'lab@anipats.com',
    '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b',
    (SELECT role_id FROM Roles WHERE role_name = 'LabStaff'),
    'Active',
    'Chris Brown',
    '+1 (555) 400-5001',
    NULL
);

-- Admin
INSERT INTO Users (email, password, role_id, status, full_name, phone, address)
VALUES (
    'admin@anipats.com',
    '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b',
    (SELECT role_id FROM Roles WHERE role_name = 'Admin'),
    'Active',
    'Admin User',
    '+1 (555) 000-0001',
    NULL
);
GO

/* ========= USER SUB TYPES ========= */
INSERT INTO Customers (user_id)
SELECT user_id FROM Users WHERE email = 'dev@anipats.com';
INSERT INTO Customers (user_id)
SELECT user_id FROM Users WHERE email = 'mary.wilson@email.com';

INSERT INTO Veterinarians (user_id, specialization)
SELECT user_id, 'General Practice' FROM Users WHERE email = 'dr.smith@anipats.com';
INSERT INTO Veterinarians (user_id, specialization)
SELECT user_id, 'Surgery' FROM Users WHERE email = 'dr.james@anipats.com';

INSERT INTO Receptionists (user_id)
SELECT user_id FROM Users WHERE email = 'reception@anipats.com';

INSERT INTO LabStaff (user_id, position)
SELECT user_id, 'Lab Technician' FROM Users WHERE email = 'lab@anipats.com';
GO

/* ========= PETS ========= */
INSERT INTO Pets (customer_id, name, species, breed, gender, birth_date, weight)
SELECT c.customer_id, 'Max', 'Dog', 'Golden Retriever', 'M', '2020-03-15', 28.5
FROM Customers c JOIN Users u ON c.user_id = u.user_id WHERE u.email = 'dev@anipats.com';

INSERT INTO Pets (customer_id, name, species, breed, gender, birth_date, weight)
SELECT c.customer_id, 'Luna', 'Cat', 'Siamese', 'F', '2021-07-20', 4.2
FROM Customers c JOIN Users u ON c.user_id = u.user_id WHERE u.email = 'dev@anipats.com';

INSERT INTO Pets (customer_id, name, species, breed, gender, birth_date, weight)
SELECT c.customer_id, 'Buddy', 'Dog', 'Labrador', 'M', '2019-11-08', 32.0
FROM Customers c JOIN Users u ON c.user_id = u.user_id WHERE u.email = 'mary.wilson@email.com';
GO

/* ========= SERVICES ========= */
INSERT INTO Services (name, price, description) VALUES
('General Checkup', 50.00, 'Routine health examination'),
('Vaccination', 35.00, 'Core vaccination'),
('Dental Cleaning', 80.00, 'Teeth cleaning and examination'),
('Blood Test', 45.00, 'Basic blood panel'),
('X-Ray', 120.00, 'Radiology'),
('Surgery Consultation', 75.00, 'Pre-surgery assessment'),
('Emergency Visit', 150.00, 'Emergency care');
GO

/* ========= APPOINTMENTS ========= */
INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status)
SELECT p.pet_id, p.customer_id, v.veterinarian_id, DATEADD(day, -7, GETDATE()), 'Completed'
FROM Pets p
CROSS JOIN (SELECT TOP 1 veterinarian_id FROM Veterinarians) v
JOIN Customers c ON p.customer_id = c.customer_id
JOIN Users u ON c.user_id = u.user_id
WHERE u.email = 'dev@anipats.com' AND p.name = 'Max';

INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status)
SELECT p.pet_id, p.customer_id, v.veterinarian_id, DATEADD(day, 3, GETDATE()), 'Scheduled'
FROM Pets p
CROSS JOIN (SELECT TOP 1 veterinarian_id FROM Veterinarians) v
JOIN Customers c ON p.customer_id = c.customer_id
JOIN Users u ON c.user_id = u.user_id
WHERE u.email = 'dev@anipats.com' AND p.name = 'Luna';

INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status)
SELECT p.pet_id, p.customer_id, v.veterinarian_id, DATEADD(day, 5, GETDATE()), 'Scheduled'
FROM Pets p
CROSS JOIN (SELECT TOP 1 veterinarian_id FROM Veterinarians ORDER BY veterinarian_id DESC) v
JOIN Customers c ON p.customer_id = c.customer_id
JOIN Users u ON c.user_id = u.user_id
WHERE u.email = 'mary.wilson@email.com' AND p.name = 'Buddy';
GO

/* ========= VISITS ========= */
INSERT INTO Visits (appointment_id, pet_id, customer_id, check_in_time, check_out_time, visit_status, staff_id, veterinarian_id)
SELECT a.appointment_id, a.pet_id, a.customer_id,
       DATEADD(hour, -2, a.appointment_time),
       DATEADD(hour, -1, a.appointment_time),
       'Completed',
       (SELECT TOP 1 receptionist_id FROM Receptionists),
       a.veterinarian_id
FROM Appointments a
WHERE a.status = 'Completed';
GO

/* ========= MEDICAL RECORDS ========= */
INSERT INTO MedicalRecords (visit_id, veterinarian_id, diagnosis, treatment, note)
SELECT v.visit_id, v.veterinarian_id,
       'Routine checkup - healthy',
       'Vaccination booster administered',
       'Pet in good condition. Next checkup in 1 year.'
FROM Visits v
WHERE v.visit_status = 'Completed';
GO

/* ========= MEDICAL RECORD SERVICES ========= */
INSERT INTO MedicalRecordServices (record_id, service_id, quantity, price)
SELECT mr.record_id, s.service_id, 1, s.price
FROM MedicalRecords mr
CROSS JOIN (SELECT service_id FROM Services WHERE name = 'General Checkup') s;

INSERT INTO MedicalRecordServices (record_id, service_id, quantity, price)
SELECT mr.record_id, s.service_id, 1, s.price
FROM MedicalRecords mr
CROSS JOIN (SELECT service_id FROM Services WHERE name = 'Vaccination') s;
GO

/* ========= PRESCRIPTIONS ========= */
INSERT INTO Prescriptions (record_id, medicine_name, dosage, duration)
SELECT record_id, 'Flea prevention (monthly)', '1 tablet per month', '12 months'
FROM MedicalRecords;
GO

/* ========= LAB TESTS ========= */
INSERT INTO LabTests (test_name, description, normal_range, unit, status) VALUES
('Complete Blood Count', 'CBC panel', 'Varies by species', 'N/A', 'Active'),
('Blood Glucose', 'Glucose level', '70-120', 'mg/dL', 'Active'),
('Kidney Panel', 'BUN, Creatinine', 'Varies', 'mg/dL', 'Active');
GO

/* ========= LAB TEST REQUESTS & RESULTS ========= */
INSERT INTO LabTestRequests (visit_id, test_id, veterinarian_id, status)
SELECT v.visit_id, (SELECT TOP 1 test_id FROM LabTests), v.veterinarian_id, 'Completed'
FROM Visits v
WHERE v.visit_status = 'Completed';

INSERT INTO LabTestResults (request_id, result_value, result_note, lab_staff_id)
SELECT ltr.request_id, 'Within normal range', 'No abnormalities', (SELECT TOP 1 staff_id FROM LabStaff)
FROM LabTestRequests ltr
WHERE ltr.status = 'Completed';
GO

/* ========= INVOICES ========= */
INSERT INTO Invoices (visit_id, total_amount, status)
SELECT v.visit_id, 85.00, 'Paid'
FROM Visits v
WHERE v.visit_status = 'Completed';

INSERT INTO InvoiceItems (invoice_id, item_type, ref_id, name_snapshot, unit_price, quantity, total_price)
SELECT i.invoice_id, 'Service', NULL, 'General Checkup', 50.00, 1, 50.00
FROM Invoices i;

INSERT INTO InvoiceItems (invoice_id, item_type, ref_id, name_snapshot, unit_price, quantity, total_price)
SELECT i.invoice_id, 'Service', NULL, 'Vaccination', 35.00, 1, 35.00
FROM Invoices i;
GO

/* ========= NOTIFICATIONS ========= */
INSERT INTO Notifications (user_id, title, message)
SELECT u.user_id, 'Appointment Reminder', 'Your appointment for Luna is in 3 days.'
FROM Users u WHERE u.email = 'dev@anipats.com';

INSERT INTO Notifications (user_id, title, message)
SELECT u.user_id, 'Welcome', 'Thank you for choosing Anipats. We care for your pets.'
FROM Users u WHERE u.email = 'mary.wilson@email.com';
GO

/* ========= BLOGS ========= */
INSERT INTO Blogs (title, content) VALUES
('5 Signs Your Pet Needs a Checkup', 'Regular vet visits are essential. Here are five signs that indicate it might be time for a checkup: changes in appetite, lethargy, unusual behavior, vomiting or diarrhea, and difficulty breathing.'),
('Vaccination Schedule for Dogs', 'Core vaccines for dogs include rabies, distemper, parvovirus, and adenovirus. Your veterinarian can tailor a schedule based on your dog''s age and lifestyle.'),
('Dental Care for Cats', 'Dental disease is common in cats. Brushing teeth, dental treats, and annual cleanings can help keep your cat''s mouth healthy.');
GO

PRINT 'Seed data inserted successfully.';
PRINT 'Login (password for all): dev123';
PRINT '  Customer:    dev@anipats.com, mary.wilson@email.com';
PRINT '  Vet:         dr.smith@anipats.com, dr.james@anipats.com';
PRINT '  Reception:   reception@anipats.com';
PRINT '  Lab:         lab@anipats.com';
PRINT '  Admin:       admin@anipats.com';
GO

/* ===============================
   TEST DATA FOR SCREENS
   Run after seed_data.sql
   Adds TODAY's appointments so Vet Queue, Receptionist, and Examination screens have data.
   Password for all: dev123
   =============================== */

USE VetClinicManagement1;
GO

/* ========= TODAY'S APPOINTMENTS (for Vet Queue & Receptionist list) ========= */
/* Dr. Sarah Smith (dr.smith@anipats.com) - 2 appointments today */
INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status)
SELECT p.pet_id, c.customer_id, v.veterinarian_id,
       DATEADD(hour, 9, CAST(CAST(GETDATE() AS DATE) AS DATETIME)),  /* 09:00 today */
       'Confirmed'
FROM Pets p
JOIN Customers c ON p.customer_id = c.customer_id
JOIN Users u ON c.user_id = u.user_id
CROSS JOIN (SELECT veterinarian_id FROM Veterinarians WHERE user_id = (SELECT user_id FROM Users WHERE email = 'dr.smith@anipats.com')) v
WHERE u.email = 'dev@anipats.com' AND p.name = 'Max';

INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status)
SELECT p.pet_id, c.customer_id, v.veterinarian_id,
       DATEADD(hour, 10, DATEADD(minute, 30, CAST(CAST(GETDATE() AS DATE) AS DATETIME))),  /* 10:30 today */
       'Confirmed'
FROM Pets p
JOIN Customers c ON p.customer_id = c.customer_id
JOIN Users u ON c.user_id = u.user_id
CROSS JOIN (SELECT veterinarian_id FROM Veterinarians WHERE user_id = (SELECT user_id FROM Users WHERE email = 'dr.smith@anipats.com')) v
WHERE u.email = 'dev@anipats.com' AND p.name = 'Luna';

/* Dr. James Lee (dr.james@anipats.com) - 2 appointments today */
INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status)
SELECT p.pet_id, c.customer_id, v.veterinarian_id,
       DATEADD(hour, 11, CAST(CAST(GETDATE() AS DATE) AS DATETIME)),  /* 11:00 today */
       'Confirmed'
FROM Pets p
JOIN Customers c ON p.customer_id = c.customer_id
JOIN Users u ON c.user_id = u.user_id
CROSS JOIN (SELECT veterinarian_id FROM Veterinarians WHERE user_id = (SELECT user_id FROM Users WHERE email = 'dr.james@anipats.com')) v
WHERE u.email = 'mary.wilson@email.com' AND p.name = 'Buddy';

INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status)
SELECT p.pet_id, c.customer_id, v.veterinarian_id,
       DATEADD(hour, 14, CAST(CAST(GETDATE() AS DATE) AS DATETIME)),  /* 14:00 today */
       'Confirmed'
FROM Pets p
JOIN Customers c ON p.customer_id = c.customer_id
JOIN Users u ON c.user_id = u.user_id
CROSS JOIN (SELECT veterinarian_id FROM Veterinarians WHERE user_id = (SELECT user_id FROM Users WHERE email = 'dr.james@anipats.com')) v
WHERE u.email = 'dev@anipats.com' AND p.name = 'Max';

/* ========= ONE CHECKED-IN VISIT (for Vet Queue + Lab Dashboard) ========= */
/* Vet queue shows only status = ''Checked-in''; receptionist creates visit with staff_id. */
/* This inserts one visit as if receptionist had already checked in the first appointment. */
INSERT INTO Visits (appointment_id, pet_id, customer_id, check_in_time, visit_status, staff_id, veterinarian_id)
SELECT TOP 1 a.appointment_id, a.pet_id, a.customer_id, GETDATE(), 'Checked-in',
       (SELECT TOP 1 receptionist_id FROM Receptionists),
       a.veterinarian_id
FROM Appointments a
WHERE a.status = 'Confirmed' AND CAST(a.appointment_time AS DATE) = CAST(GETDATE() AS DATE)
ORDER BY a.appointment_time;

/* Update that appointment to Checked-in so it matches the visit */
UPDATE a SET a.status = 'Checked-in'
FROM Appointments a
WHERE a.appointment_id IN (SELECT TOP 1 appointment_id FROM Visits WHERE visit_status = 'Checked-in' ORDER BY visit_id DESC);

/* One Pending lab request for that visit (Lab Dashboard) */
INSERT INTO LabTestRequests (visit_id, test_id, veterinarian_id, status)
SELECT TOP 1 v.visit_id, (SELECT TOP 1 test_id FROM LabTests), v.veterinarian_id, 'Pending'
FROM Visits v
WHERE v.visit_status = 'Checked-in'
ORDER BY v.visit_id DESC;

GO

PRINT 'Test screen data inserted.';
PRINT 'Today''s appointments: 4 total (2 for Dr. Sarah Smith, 2 for Dr. James Lee).';
PRINT 'One appointment is pre-checked-in (appears in Vet Queue). Other 3: use Staff Queue as reception@anipats.com and click Check-in.';
PRINT 'Vet Queue: dr.smith@anipats.com or dr.james@anipats.com. Lab: lab@anipats.com.';
GO

/* ========= EXTRA UNIQUE COMPLETED VISITS & RECORDS (for history screens) ========= */
/* These create additional, varied medical records so vet/customer history pages have more realistic data. */

/* Completed visit #1: Max – Ear infection follow-up (Dr. Sarah Smith, Paid) */
DECLARE @maxPetId INT = (SELECT TOP 1 p.pet_id FROM Pets p JOIN Customers c ON p.customer_id = c.customer_id
                          JOIN Users u ON c.user_id = u.user_id
                          WHERE u.email = 'dev@anipats.com' AND p.name = 'Max');
DECLARE @maxCustomerId INT = (SELECT TOP 1 c.customer_id FROM Customers c JOIN Users u ON c.user_id = u.user_id
                               WHERE u.email = 'dev@anipats.com');
DECLARE @vetSarahId INT = (SELECT TOP 1 veterinarian_id FROM Veterinarians v
                            JOIN Users u ON v.user_id = u.user_id
                            WHERE u.email = 'dr.smith@anipats.com');
DECLARE @staffId INT = (SELECT TOP 1 receptionist_id FROM Receptionists);

IF @maxPetId IS NOT NULL AND @maxCustomerId IS NOT NULL AND @vetSarahId IS NOT NULL AND @staffId IS NOT NULL
BEGIN
    DECLARE @appt1 INT;
    INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status)
    VALUES (@maxPetId, @maxCustomerId, @vetSarahId, DATEADD(day, -3, GETDATE()), 'Completed');
    SET @appt1 = SCOPE_IDENTITY();

    DECLARE @visit1 INT;
    INSERT INTO Visits (appointment_id, pet_id, customer_id, check_in_time, check_out_time, visit_status, staff_id, veterinarian_id)
    VALUES (@appt1, @maxPetId, @maxCustomerId,
            DATEADD(hour, -1, DATEADD(day, -3, GETDATE())),
            DATEADD(minute, -30, DATEADD(day, -3, GETDATE())),
            'Completed', @staffId, @vetSarahId);
    SET @visit1 = SCOPE_IDENTITY();

    DECLARE @record1 INT;
    INSERT INTO MedicalRecords (visit_id, veterinarian_id, diagnosis, treatment, note)
    VALUES (@visit1, @vetSarahId,
            'Chronic otitis externa (ear infection), mild flare-up',
            'Clean ear canal, prescribe topical antibiotic drops for 7 days',
            'Owner reports scratching and head shaking. Mild erythema in ear canal, no systemic signs.');
    SET @record1 = SCOPE_IDENTITY();

    /* Services: General Checkup + Blood Test */
    INSERT INTO MedicalRecordServices (record_id, service_id, quantity, price)
    SELECT @record1, service_id, 1, price FROM Services WHERE name = 'General Checkup';
    INSERT INTO MedicalRecordServices (record_id, service_id, quantity, price)
    SELECT @record1, service_id, 1, price FROM Services WHERE name = 'Blood Test';

    /* Invoice + items */
    DECLARE @total1 DECIMAL(10,2) =
        (SELECT SUM(price * quantity) FROM MedicalRecordServices WHERE record_id = @record1);
    DECLARE @inv1 INT;
    INSERT INTO Invoices (visit_id, total_amount, status)
    VALUES (@visit1, @total1, 'Paid');
    SET @inv1 = SCOPE_IDENTITY();

    INSERT INTO InvoiceItems (invoice_id, item_type, ref_id, name_snapshot, unit_price, quantity, total_price)
    SELECT @inv1, 'Service', NULL, s.name, s.price, mrs.quantity, mrs.price * mrs.quantity
    FROM MedicalRecordServices mrs
    JOIN Services s ON mrs.service_id = s.service_id
    WHERE mrs.record_id = @record1;
END
GO

/* Completed visit #2: Luna – Gastrointestinal upset (Dr. James Lee, waiting for payment) */
DECLARE @lunaPetId INT = (SELECT TOP 1 p.pet_id FROM Pets p JOIN Customers c ON p.customer_id = c.customer_id
                           JOIN Users u ON c.user_id = u.user_id
                           WHERE u.email = 'dev@anipats.com' AND p.name = 'Luna');
DECLARE @customerDevId INT = (SELECT TOP 1 c.customer_id FROM Customers c JOIN Users u ON c.user_id = u.user_id
                               WHERE u.email = 'dev@anipats.com');
DECLARE @vetJamesId INT = (SELECT TOP 1 veterinarian_id FROM Veterinarians v
                            JOIN Users u ON v.user_id = u.user_id
                            WHERE u.email = 'dr.james@anipats.com');
DECLARE @staffId2 INT = (SELECT TOP 1 receptionist_id FROM Receptionists);

IF @lunaPetId IS NOT NULL AND @customerDevId IS NOT NULL AND @vetJamesId IS NOT NULL AND @staffId2 IS NOT NULL
BEGIN
    DECLARE @appt2 INT;
    INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status)
    VALUES (@lunaPetId, @customerDevId, @vetJamesId, DATEADD(day, -1, GETDATE()), 'Waiting-for-Payment');
    SET @appt2 = SCOPE_IDENTITY();

    DECLARE @visit2 INT;
    INSERT INTO Visits (appointment_id, pet_id, customer_id, check_in_time, check_out_time, visit_status, staff_id, veterinarian_id)
    VALUES (@appt2, @lunaPetId, @customerDevId,
            DATEADD(hour, -2, DATEADD(day, -1, GETDATE())),
            DATEADD(hour, -1, DATEADD(day, -1, GETDATE())),
            'Completed', @staffId2, @vetJamesId);
    SET @visit2 = SCOPE_IDENTITY();

    DECLARE @record2 INT;
    INSERT INTO MedicalRecords (visit_id, veterinarian_id, diagnosis, treatment, note)
    VALUES (@visit2, @vetJamesId,
            'Acute gastroenteritis, likely dietary indiscretion',
            'Prescribe bland diet and antiemetic for 3 days; recheck if no improvement.',
            'Vomiting x2 days, soft stool, mild dehydration. No foreign body on palpation.');
    SET @record2 = SCOPE_IDENTITY();

    /* Services: General Checkup + X-Ray */
    INSERT INTO MedicalRecordServices (record_id, service_id, quantity, price)
    SELECT @record2, service_id, 1, price FROM Services WHERE name = 'General Checkup';
    INSERT INTO MedicalRecordServices (record_id, service_id, quantity, price)
    SELECT @record2, service_id, 1, price FROM Services WHERE name = 'X-Ray';

    /* Invoice with status Recorded (to appear in Waiting for Payment) */
    DECLARE @total2 DECIMAL(10,2) =
        (SELECT SUM(price * quantity) FROM MedicalRecordServices WHERE record_id = @record2);
    DECLARE @inv2 INT;
    INSERT INTO Invoices (visit_id, total_amount, status)
    VALUES (@visit2, @total2, 'Recorded');
    SET @inv2 = SCOPE_IDENTITY();

    INSERT INTO InvoiceItems (invoice_id, item_type, ref_id, name_snapshot, unit_price, quantity, total_price)
    SELECT @inv2, 'Service', NULL, s.name, s.price, mrs.quantity, mrs.price * mrs.quantity
    FROM MedicalRecordServices mrs
    JOIN Services s ON mrs.service_id = s.service_id
    WHERE mrs.record_id = @record2;
END
GO

/* ================================================================
   NEW PET TEST DATA — EXAMINATION SCREEN
   Run after seed_data.sql + seed_test_screens.sql
   Creates a brand-new customer + pet with a TODAY appointment
   already in Checked-in state so it appears immediately in
   the Vet Queue / Examination page.

   New account:  sam.parker@email.com / dev123
   New pet:      Rex (German Shepherd, Male, 3 yrs, 25 kg)
   Assigned vet: dr.smith@anipats.com (Dr. Sarah Smith)
   ================================================================ */

USE VetClinicManagement1;
GO

/* ── 1. New customer user ── */
IF NOT EXISTS (SELECT 1 FROM Users WHERE email = 'sam.parker@email.com')
BEGIN
    INSERT INTO Users (email, password, role_id, status, full_name, phone, address)
    VALUES (
        'sam.parker@email.com',
        '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b', /* dev123 */
        (SELECT role_id FROM Roles WHERE role_name = 'Customer'),
        'Active',
        'Sam Parker',
        '+1 (555) 100-3001',
        '789 Maple Ave, Queens, NY'
    );

    INSERT INTO Customers (user_id)
    SELECT user_id FROM Users WHERE email = 'sam.parker@email.com';
END
GO

/* ── 2. New pet ── */
IF NOT EXISTS (
    SELECT 1 FROM Pets p
    JOIN Customers c ON p.customer_id = c.customer_id
    JOIN Users u ON c.user_id = u.user_id
    WHERE u.email = 'sam.parker@email.com' AND p.name = 'Rex'
)
BEGIN
    INSERT INTO Pets (customer_id, name, species, breed, gender, birth_date, weight)
    SELECT c.customer_id,
           'Rex',
           'Dog',
           'German Shepherd',
           'M',
           DATEADD(year, -3, CAST(GETDATE() AS DATE)),  /* 3 years old today */
           25.00
    FROM Customers c
    JOIN Users u ON c.user_id = u.user_id
    WHERE u.email = 'sam.parker@email.com';
END
GO

/* ── 3. Appointment for TODAY (Checked-in) ── */
DECLARE @rexPetId       INT = (
    SELECT TOP 1 p.pet_id
    FROM Pets p
    JOIN Customers c ON p.customer_id = c.customer_id
    JOIN Users u ON c.user_id = u.user_id
    WHERE u.email = 'sam.parker@email.com' AND p.name = 'Rex'
);
DECLARE @samCustomerId  INT = (
    SELECT TOP 1 c.customer_id
    FROM Customers c
    JOIN Users u ON c.user_id = u.user_id
    WHERE u.email = 'sam.parker@email.com'
);
DECLARE @vetSarahId     INT = (
    SELECT TOP 1 veterinarian_id
    FROM Veterinarians v
    JOIN Users u ON v.user_id = u.user_id
    WHERE u.email = 'dr.smith@anipats.com'
);
DECLARE @staffId        INT = (SELECT TOP 1 receptionist_id FROM Receptionists);
DECLARE @generalCheckup INT = (SELECT TOP 1 service_id FROM Services WHERE name = 'General Checkup');

IF @rexPetId IS NOT NULL AND @samCustomerId IS NOT NULL AND @vetSarahId IS NOT NULL
BEGIN
    /* Appointment at current time, status Checked-in */
    DECLARE @apptId INT;
    INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status, service_id)
    VALUES (
        @rexPetId,
        @samCustomerId,
        @vetSarahId,
        DATEADD(minute, 30, CAST(CAST(GETDATE() AS DATE) AS DATETIME)), /* 00:30 today — always "today" */
        'Checked-in',
        @generalCheckup
    );
    SET @apptId = SCOPE_IDENTITY();

    /* Visit — already checked in, open for examination */
    INSERT INTO Visits (appointment_id, pet_id, customer_id, check_in_time, visit_status, staff_id, veterinarian_id)
    VALUES (
        @apptId,
        @rexPetId,
        @samCustomerId,
        GETDATE(),
        'Checked-in',
        @staffId,
        @vetSarahId
    );

    PRINT '========================================================';
    PRINT 'New pet data inserted successfully.';
    PRINT '';
    PRINT '  Customer:  Sam Parker (sam.parker@email.com / dev123)';
    PRINT '  Pet:       Rex — German Shepherd, Male, 3 yrs, 25 kg';
    PRINT '  Vet:       Dr. Sarah Smith (dr.smith@anipats.com)';
    PRINT '  Status:    Checked-in — ready for examination';
    PRINT '';
    PRINT 'Open examination:';
    PRINT '  Login as dr.smith@anipats.com, go to Vet Queue,';
    PRINT '  click "Start Examination" for Rex.';
    PRINT '========================================================';
END
ELSE
BEGIN
    PRINT 'ERROR: Could not find required records (pet/customer/vet). Make sure seed_data.sql was run first.';
END
GO

/* =====================================================================
   SCHEMA UPGRADE TO CURRENT APP MODEL (slot-based appointments)
   - Keeps all inserted seed data
   - Converts legacy Appointments.appointment_time -> appointment_date/time_slot
   - Adds Appointments.type, phone, notes, arrival_time
   - Aligns Users.password + Users.phone data types
   ===================================================================== */
USE [VetClinicManagement1]
GO

UPDATE u
SET u.phone = LEFT(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(u.phone, ''), '+', ''), '(', ''), ')', ''), '-', ''), ' ', ''),
    15
)
FROM dbo.Users u;
GO

UPDATE dbo.Users
SET phone = '0000000000'
WHERE phone IS NULL OR LTRIM(RTRIM(phone)) = '';
GO

ALTER TABLE dbo.Users ALTER COLUMN [phone] VARCHAR(15) NOT NULL;
GO

ALTER TABLE dbo.Users ALTER COLUMN [password] VARCHAR(255) NULL;
GO

IF COL_LENGTH('dbo.Appointments', 'notes') IS NULL
    ALTER TABLE dbo.Appointments ADD [notes] NVARCHAR(1000) NULL;
GO

IF COL_LENGTH('dbo.Appointments', 'appointment_date') IS NULL
    ALTER TABLE dbo.Appointments ADD [appointment_date] DATE NULL;
GO

IF COL_LENGTH('dbo.Appointments', 'time_slot') IS NULL
    ALTER TABLE dbo.Appointments ADD [time_slot] NVARCHAR(2) NULL;
GO

IF COL_LENGTH('dbo.Appointments', 'type') IS NULL
    ALTER TABLE dbo.Appointments ADD [type] VARCHAR(20) NULL;
GO

IF COL_LENGTH('dbo.Appointments', 'phone') IS NULL
    ALTER TABLE dbo.Appointments ADD [phone] VARCHAR(10) NULL;
GO

IF COL_LENGTH('dbo.Appointments', 'arrival_time') IS NULL
    ALTER TABLE dbo.Appointments ADD [arrival_time] TIME(7) NULL;
GO

UPDATE dbo.Appointments
SET appointment_date = CAST(appointment_time AS DATE)
WHERE appointment_date IS NULL AND appointment_time IS NOT NULL;
GO

UPDATE dbo.Appointments
SET time_slot = CASE WHEN DATEPART(HOUR, appointment_time) < 12 THEN 'AM' ELSE 'PM' END
WHERE time_slot IS NULL AND appointment_time IS NOT NULL;
GO

UPDATE a
SET a.phone = RIGHT(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(u.phone, '0000000000'), '+', ''), '(', ''), ')', ''), '-', ''), ' ', ''),
    10
)
FROM dbo.Appointments a
JOIN dbo.Customers c ON c.customer_id = a.customer_id
JOIN dbo.Users u ON u.user_id = c.user_id
WHERE a.phone IS NULL;
GO

UPDATE dbo.Appointments
SET phone = '0000000000'
WHERE phone IS NULL OR LEN(phone) < 10;
GO

UPDATE dbo.Appointments
SET [type] = 'Normal'
WHERE [type] IS NULL;
GO

UPDATE a
SET a.arrival_time = CAST(v.check_in_time AS TIME(7))
FROM dbo.Appointments a
JOIN dbo.Visits v ON v.appointment_id = a.appointment_id
WHERE a.arrival_time IS NULL AND v.check_in_time IS NOT NULL;
GO

ALTER TABLE dbo.Appointments ALTER COLUMN [type] VARCHAR(20) NOT NULL;
GO

ALTER TABLE dbo.Appointments ALTER COLUMN [phone] VARCHAR(10) NOT NULL;
GO

IF OBJECT_ID('dbo.DF_appointment_type', 'D') IS NULL
BEGIN
    ALTER TABLE dbo.Appointments ADD CONSTRAINT [DF_appointment_type] DEFAULT ('Normal') FOR [type];
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_appointment_type'
      AND parent_object_id = OBJECT_ID('dbo.Appointments')
)
BEGIN
    ALTER TABLE dbo.Appointments
    WITH CHECK ADD CONSTRAINT [CK_appointment_type]
    CHECK ([type] = 'Emergency' OR [type] = 'Normal');
END
GO

ALTER TABLE dbo.Appointments CHECK CONSTRAINT [CK_appointment_type];
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_Appointments_TimeSlot'
      AND parent_object_id = OBJECT_ID('dbo.Appointments')
)
BEGIN
    ALTER TABLE dbo.Appointments
    WITH CHECK ADD CONSTRAINT [CK_Appointments_TimeSlot]
    CHECK ([time_slot] = 'AM' OR [time_slot] = 'PM');
END
GO

ALTER TABLE dbo.Appointments CHECK CONSTRAINT [CK_Appointments_TimeSlot];
GO

IF COL_LENGTH('dbo.Appointments', 'appointment_time') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Appointments DROP COLUMN [appointment_time];
END
GO

/* =====================================================================
   EXTRA SAMPLE DATA (ensures medical records are always available)
   ===================================================================== */
USE [VetClinicManagement1]
GO

/* 1) Backfill medical records for completed visits that do not have one yet. */
IF EXISTS (SELECT 1 FROM dbo.Veterinarians)
BEGIN
    INSERT INTO dbo.MedicalRecords (visit_id, veterinarian_id, diagnosis, treatment, note, created_at)
    SELECT
        v.visit_id,
        COALESCE(v.veterinarian_id, (SELECT TOP 1 veterinarian_id FROM dbo.Veterinarians ORDER BY veterinarian_id)),
        N'General wellness examination',
        N'Preventive care advised; continue routine monitoring.',
        N'Auto-generated sample medical record for completed visit.',
        GETDATE()
    FROM dbo.Visits v
    LEFT JOIN dbo.MedicalRecords mr ON mr.visit_id = v.visit_id
    WHERE v.visit_status = 'Completed'
      AND mr.record_id IS NULL;
END
GO

/* 2) Fallback: if still empty, create one completed appointment/visit/record. */
IF NOT EXISTS (SELECT 1 FROM dbo.MedicalRecords)
BEGIN
    DECLARE @fallbackVetId INT = (SELECT TOP 1 veterinarian_id FROM dbo.Veterinarians ORDER BY veterinarian_id);
    DECLARE @fallbackStaffId INT = (SELECT TOP 1 receptionist_id FROM dbo.Receptionists ORDER BY receptionist_id);
    DECLARE @fallbackServiceId INT = (SELECT TOP 1 service_id FROM dbo.Services ORDER BY service_id);
    DECLARE @fallbackPetId INT = (SELECT TOP 1 pet_id FROM dbo.Pets ORDER BY pet_id);
    DECLARE @fallbackCustomerId INT = (SELECT TOP 1 customer_id FROM dbo.Customers ORDER BY customer_id);
    DECLARE @fallbackPhone VARCHAR(10) = (
        SELECT TOP 1 RIGHT(
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(u.phone, '0000000000'), '+', ''), '(', ''), ')', ''), '-', ''), ' ', ''),
            10
        )
        FROM dbo.Customers c
        JOIN dbo.Users u ON u.user_id = c.user_id
        WHERE c.customer_id = @fallbackCustomerId
    );

    IF @fallbackPhone IS NULL OR LEN(@fallbackPhone) < 10
        SET @fallbackPhone = '0000000000';

    IF @fallbackVetId IS NOT NULL AND @fallbackPetId IS NOT NULL AND @fallbackCustomerId IS NOT NULL
    BEGIN
        DECLARE @fallbackAppointmentId INT;
        INSERT INTO dbo.Appointments (
            pet_id,
            customer_id,
            veterinarian_id,
            status,
            created_at,
            service_id,
            notes,
            appointment_date,
            time_slot,
            type,
            phone,
            arrival_time
        )
        VALUES (
            @fallbackPetId,
            @fallbackCustomerId,
            @fallbackVetId,
            'Completed',
            GETDATE(),
            @fallbackServiceId,
            N'Auto-created fallback appointment for sample medical record.',
            CAST(GETDATE() AS DATE),
            CASE WHEN DATEPART(HOUR, GETDATE()) < 12 THEN 'AM' ELSE 'PM' END,
            'Normal',
            @fallbackPhone,
            CAST(GETDATE() AS TIME(7))
        );
        SET @fallbackAppointmentId = SCOPE_IDENTITY();

        DECLARE @fallbackVisitId INT;
        INSERT INTO dbo.Visits (
            appointment_id,
            pet_id,
            customer_id,
            check_in_time,
            check_out_time,
            visit_status,
            staff_id,
            veterinarian_id
        )
        VALUES (
            @fallbackAppointmentId,
            @fallbackPetId,
            @fallbackCustomerId,
            DATEADD(minute, -20, GETDATE()),
            GETDATE(),
            'Completed',
            @fallbackStaffId,
            @fallbackVetId
        );
        SET @fallbackVisitId = SCOPE_IDENTITY();

        INSERT INTO dbo.MedicalRecords (visit_id, veterinarian_id, diagnosis, treatment, note, created_at)
        VALUES (
            @fallbackVisitId,
            @fallbackVetId,
            N'Initial wellness check',
            N'No treatment required; maintain regular vaccination schedule.',
            N'Fallback medical record generated to ensure sample data completeness.',
            GETDATE()
        );
    END
END
GO

/* 3) Add one extra completed sample case for demo data richness. */
IF NOT EXISTS (
    SELECT 1
    FROM dbo.MedicalRecords
    WHERE note = N'Extra sample record: dental follow-up'
)
BEGIN
    DECLARE @extraVetId INT = (SELECT TOP 1 veterinarian_id FROM dbo.Veterinarians ORDER BY veterinarian_id DESC);
    DECLARE @extraStaffId INT = (SELECT TOP 1 receptionist_id FROM dbo.Receptionists ORDER BY receptionist_id);
    DECLARE @extraServiceId INT = (
        SELECT TOP 1 service_id
        FROM dbo.Services
        WHERE name IN (N'Dental Cleaning', N'General Checkup')
        ORDER BY CASE WHEN name = N'Dental Cleaning' THEN 0 ELSE 1 END, service_id
    );
    DECLARE @extraPetId INT = (SELECT TOP 1 pet_id FROM dbo.Pets ORDER BY pet_id DESC);
    DECLARE @extraCustomerId INT = (SELECT TOP 1 customer_id FROM dbo.Pets WHERE pet_id = @extraPetId);
    DECLARE @extraPhone VARCHAR(10) = (
        SELECT TOP 1 RIGHT(
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(u.phone, '0000000000'), '+', ''), '(', ''), ')', ''), '-', ''), ' ', ''),
            10
        )
        FROM dbo.Customers c
        JOIN dbo.Users u ON u.user_id = c.user_id
        WHERE c.customer_id = @extraCustomerId
    );

    IF @extraPhone IS NULL OR LEN(@extraPhone) < 10
        SET @extraPhone = '0000000000';

    IF @extraVetId IS NOT NULL AND @extraPetId IS NOT NULL AND @extraCustomerId IS NOT NULL
    BEGIN
        DECLARE @extraAppointmentId INT;
        INSERT INTO dbo.Appointments (
            pet_id,
            customer_id,
            veterinarian_id,
            status,
            created_at,
            service_id,
            notes,
            appointment_date,
            time_slot,
            type,
            phone,
            arrival_time
        )
        VALUES (
            @extraPetId,
            @extraCustomerId,
            @extraVetId,
            'Completed',
            GETDATE(),
            @extraServiceId,
            N'Extra sample case for medical history screen.',
            CAST(DATEADD(day, -2, GETDATE()) AS DATE),
            'PM',
            'Normal',
            @extraPhone,
            CAST(DATEADD(day, -2, GETDATE()) AS TIME(7))
        );
        SET @extraAppointmentId = SCOPE_IDENTITY();

        DECLARE @extraVisitId INT;
        INSERT INTO dbo.Visits (
            appointment_id,
            pet_id,
            customer_id,
            check_in_time,
            check_out_time,
            visit_status,
            staff_id,
            veterinarian_id
        )
        VALUES (
            @extraAppointmentId,
            @extraPetId,
            @extraCustomerId,
            DATEADD(day, -2, DATEADD(minute, -35, GETDATE())),
            DATEADD(day, -2, GETDATE()),
            'Completed',
            @extraStaffId,
            @extraVetId
        );
        SET @extraVisitId = SCOPE_IDENTITY();

        DECLARE @extraRecordId INT;
        INSERT INTO dbo.MedicalRecords (visit_id, veterinarian_id, diagnosis, treatment, note, created_at)
        VALUES (
            @extraVisitId,
            @extraVetId,
            N'Mild periodontal inflammation',
            N'Dental cleaning and oral hygiene guidance.',
            N'Extra sample record: dental follow-up',
            DATEADD(day, -2, GETDATE())
        );
        SET @extraRecordId = SCOPE_IDENTITY();

        IF @extraServiceId IS NOT NULL
        BEGIN
            INSERT INTO dbo.MedicalRecordServices (record_id, service_id, quantity, price)
            SELECT @extraRecordId, s.service_id, 1, s.price
            FROM dbo.Services s
            WHERE s.service_id = @extraServiceId;
        END

        INSERT INTO dbo.Prescriptions (record_id, medicine_name, dosage, duration)
        VALUES (@extraRecordId, N'Chlorhexidine oral rinse', N'5 ml, once daily', N'7 days');
    END
END
GO

/* 4) Ensure every medical record has at least one service and one prescription. */
IF EXISTS (SELECT 1 FROM dbo.Services)
BEGIN
    INSERT INTO dbo.MedicalRecordServices (record_id, service_id, quantity, price)
    SELECT mr.record_id, s.service_id, 1, s.price
    FROM dbo.MedicalRecords mr
    CROSS JOIN (
        SELECT TOP 1 service_id, price
        FROM dbo.Services
        ORDER BY service_id
    ) s
    LEFT JOIN dbo.MedicalRecordServices mrs ON mrs.record_id = mr.record_id
    WHERE mrs.record_id IS NULL;
END
GO

INSERT INTO dbo.Prescriptions (record_id, medicine_name, dosage, duration)
SELECT mr.record_id, N'Vitamin supplement', N'1 tablet daily', N'14 days'
FROM dbo.MedicalRecords mr
LEFT JOIN dbo.Prescriptions p ON p.record_id = mr.record_id
WHERE p.record_id IS NULL;
GO

PRINT 'Extra sample data inserted. MedicalRecords are guaranteed to exist.';
GO

/* =====================================================================
   BULK DEMO DATA (adds denser data for UI testing)
   ===================================================================== */
USE [VetClinicManagement1]
GO

DECLARE @CustomerRoleId INT = (SELECT TOP 1 role_id FROM dbo.Roles WHERE role_name = 'Customer');
DECLARE @DefaultReceptionistId INT = (SELECT TOP 1 receptionist_id FROM dbo.Receptionists ORDER BY receptionist_id);
DECLARE @DefaultLabStaffId INT = (SELECT TOP 1 staff_id FROM dbo.LabStaff ORDER BY staff_id);

IF @CustomerRoleId IS NOT NULL
BEGIN
    ;WITH N AS (
        SELECT TOP (20) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
        FROM sys.all_objects
    )
    INSERT INTO dbo.Users (email, password, role_id, status, full_name, phone, address)
    SELECT
        CONCAT('demo.customer', RIGHT('00' + CAST(n AS VARCHAR(2)), 2), '@anipats.com'),
        '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b',
        @CustomerRoleId,
        'Active',
        CONCAT('Demo Customer ', RIGHT('00' + CAST(n AS VARCHAR(2)), 2)),
        RIGHT('0900000000' + CAST(n AS VARCHAR(2)), 10),
        CONCAT(CAST(n AS VARCHAR(3)), ' Demo Street, District ', CAST(((n - 1) % 5) + 1 AS VARCHAR(1)))
    FROM N
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Users u
        WHERE u.email = CONCAT('demo.customer', RIGHT('00' + CAST(N.n AS VARCHAR(2)), 2), '@anipats.com')
    );
END
GO

INSERT INTO dbo.Customers (user_id)
SELECT u.user_id
FROM dbo.Users u
LEFT JOIN dbo.Customers c ON c.user_id = u.user_id
WHERE u.email LIKE 'demo.customer%@anipats.com'
  AND c.customer_id IS NULL;
GO

;WITH DemoCustomers AS (
    SELECT c.customer_id, ROW_NUMBER() OVER (ORDER BY c.customer_id) AS rn
    FROM dbo.Customers c
    JOIN dbo.Users u ON u.user_id = c.user_id
    WHERE u.email LIKE 'demo.customer%@anipats.com'
)
INSERT INTO dbo.Pets (customer_id, name, species, breed, gender, birth_date, weight)
SELECT
    dc.customer_id,
    CONCAT('DemoPet', RIGHT('00' + CAST(dc.rn AS VARCHAR(2)), 2), CASE WHEN p.pet_no = 1 THEN 'A' ELSE 'B' END),
    CASE WHEN p.pet_no = 1 THEN 'Dog' ELSE 'Cat' END,
    CASE
        WHEN p.pet_no = 1 AND dc.rn % 3 = 0 THEN 'Golden Retriever'
        WHEN p.pet_no = 1 THEN 'Labrador'
        WHEN dc.rn % 2 = 0 THEN 'British Shorthair'
        ELSE 'Siamese'
    END,
    CASE WHEN (dc.rn + p.pet_no) % 2 = 0 THEN 'M' ELSE 'F' END,
    DATEADD(year, -(2 + ((dc.rn + p.pet_no) % 8)), CAST(GETDATE() AS DATE)),
    CAST(4.0 + ((dc.rn * p.pet_no) % 23) AS DECIMAL(10, 2))
FROM DemoCustomers dc
CROSS JOIN (VALUES (1), (2)) p(pet_no)
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Pets x
    WHERE x.customer_id = dc.customer_id
      AND x.name = CONCAT('DemoPet', RIGHT('00' + CAST(dc.rn AS VARCHAR(2)), 2), CASE WHEN p.pet_no = 1 THEN 'A' ELSE 'B' END)
);
GO

DECLARE @VetCount INT = (SELECT COUNT(*) FROM dbo.Veterinarians);
DECLARE @ServiceCount INT = (SELECT COUNT(*) FROM dbo.Services);
DECLARE @LabTestCount INT = (SELECT COUNT(*) FROM dbo.LabTests);
DECLARE @FallbackVetId INT = (SELECT TOP 1 veterinarian_id FROM dbo.Veterinarians ORDER BY veterinarian_id);

IF @VetCount > 0 AND @ServiceCount > 0
BEGIN
    DECLARE @DemoPetPool TABLE (
        rn INT IDENTITY(1,1),
        pet_id INT,
        customer_id INT,
        phone VARCHAR(10)
    );

    DECLARE @VetPool TABLE (
        rn INT IDENTITY(1,1),
        veterinarian_id INT
    );

    DECLARE @ServicePool TABLE (
        rn INT IDENTITY(1,1),
        service_id INT,
        price DECIMAL(10,2)
    );

    INSERT INTO @DemoPetPool (pet_id, customer_id, phone)
    SELECT
        p.pet_id,
        p.customer_id,
        CASE
            WHEN LEN(RIGHT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(u.phone, '0000000000'), '+', ''), '(', ''), ')', ''), '-', ''), ' ', ''), 10)) = 10
                THEN RIGHT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(u.phone, '0000000000'), '+', ''), '(', ''), ')', ''), '-', ''), ' ', ''), 10)
            ELSE '0000000000'
        END
    FROM dbo.Pets p
    JOIN dbo.Customers c ON c.customer_id = p.customer_id
    JOIN dbo.Users u ON u.user_id = c.user_id
    WHERE u.email LIKE 'demo.customer%@anipats.com'
    ORDER BY p.pet_id;

    INSERT INTO @VetPool (veterinarian_id)
    SELECT veterinarian_id
    FROM dbo.Veterinarians
    ORDER BY veterinarian_id;

    INSERT INTO @ServicePool (service_id, price)
    SELECT service_id, ISNULL(price, 0)
    FROM dbo.Services
    ORDER BY service_id;

    INSERT INTO dbo.Appointments (
        pet_id,
        customer_id,
        veterinarian_id,
        status,
        service_id,
        notes,
        appointment_date,
        time_slot,
        type,
        phone,
        arrival_time
    )
    SELECT
        dp.pet_id,
        dp.customer_id,
        vp.veterinarian_id,
        'Completed',
        sp.service_id,
        CONCAT(N'BULK-SEED COMPLETED #', dp.rn),
        DATEADD(day, -(1 + ((dp.rn - 1) % 25)), CAST(GETDATE() AS DATE)),
        CASE WHEN dp.rn % 2 = 0 THEN 'AM' ELSE 'PM' END,
        CASE WHEN dp.rn % 9 = 0 THEN 'Emergency' ELSE 'Normal' END,
        dp.phone,
        CAST(DATEADD(minute, (dp.rn * 13) % 600, CAST('08:00:00' AS DATETIME)) AS TIME(7))
    FROM (SELECT TOP (30) * FROM @DemoPetPool ORDER BY rn) dp
    JOIN @VetPool vp ON vp.rn = ((dp.rn - 1) % @VetCount) + 1
    JOIN @ServicePool sp ON sp.rn = ((dp.rn - 1) % @ServiceCount) + 1
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Appointments a
        WHERE a.notes = CONCAT(N'BULK-SEED COMPLETED #', dp.rn)
    );

    INSERT INTO dbo.Appointments (
        pet_id,
        customer_id,
        veterinarian_id,
        status,
        service_id,
        notes,
        appointment_date,
        time_slot,
        type,
        phone,
        arrival_time
    )
    SELECT
        dp.pet_id,
        dp.customer_id,
        vp.veterinarian_id,
        CASE WHEN dp.rn % 3 = 0 THEN 'Confirmed' ELSE 'Scheduled' END,
        sp.service_id,
        CONCAT(N'BULK-SEED UPCOMING #', dp.rn),
        DATEADD(day, (1 + ((dp.rn - 1) % 14)), CAST(GETDATE() AS DATE)),
        CASE WHEN dp.rn % 2 = 0 THEN 'PM' ELSE 'AM' END,
        'Normal',
        dp.phone,
        NULL
    FROM (SELECT TOP (14) * FROM @DemoPetPool ORDER BY rn DESC) dp
    JOIN @VetPool vp ON vp.rn = ((dp.rn - 1) % @VetCount) + 1
    JOIN @ServicePool sp ON sp.rn = ((dp.rn - 1) % @ServiceCount) + 1
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Appointments a
        WHERE a.notes = CONCAT(N'BULK-SEED UPCOMING #', dp.rn)
    );

    INSERT INTO dbo.Appointments (
        pet_id,
        customer_id,
        veterinarian_id,
        status,
        service_id,
        notes,
        appointment_date,
        time_slot,
        type,
        phone,
        arrival_time
    )
    SELECT
        dp.pet_id,
        dp.customer_id,
        vp.veterinarian_id,
        'Checked-in',
        sp.service_id,
        CONCAT(N'BULK-SEED CHECKEDIN #', dp.rn),
        CAST(GETDATE() AS DATE),
        CASE WHEN dp.rn % 2 = 0 THEN 'AM' ELSE 'PM' END,
        'Normal',
        dp.phone,
        CAST(DATEADD(minute, -((dp.rn * 5) % 120), GETDATE()) AS TIME(7))
    FROM (SELECT TOP (8) * FROM @DemoPetPool ORDER BY rn) dp
    JOIN @VetPool vp ON vp.rn = ((dp.rn - 1) % @VetCount) + 1
    JOIN @ServicePool sp ON sp.rn = ((dp.rn - 1) % @ServiceCount) + 1
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Appointments a
        WHERE a.notes = CONCAT(N'BULK-SEED CHECKEDIN #', dp.rn)
    );

    INSERT INTO dbo.Visits (
        appointment_id,
        pet_id,
        customer_id,
        check_in_time,
        check_out_time,
        visit_status,
        staff_id,
        veterinarian_id
    )
    SELECT
        a.appointment_id,
        a.pet_id,
        a.customer_id,
        DATEADD(minute, -40, DATEADD(hour, CASE WHEN a.time_slot = 'AM' THEN 9 ELSE 15 END, CAST(a.appointment_date AS DATETIME))),
        DATEADD(minute, 35, DATEADD(hour, CASE WHEN a.time_slot = 'AM' THEN 9 ELSE 15 END, CAST(a.appointment_date AS DATETIME))),
        'Completed',
        @DefaultReceptionistId,
        a.veterinarian_id
    FROM dbo.Appointments a
    WHERE a.notes LIKE N'BULK-SEED COMPLETED #%'
      AND NOT EXISTS (
          SELECT 1 FROM dbo.Visits v WHERE v.appointment_id = a.appointment_id
      );

    INSERT INTO dbo.Visits (
        appointment_id,
        pet_id,
        customer_id,
        check_in_time,
        check_out_time,
        visit_status,
        staff_id,
        veterinarian_id
    )
    SELECT
        a.appointment_id,
        a.pet_id,
        a.customer_id,
        GETDATE(),
        NULL,
        'Checked-in',
        @DefaultReceptionistId,
        a.veterinarian_id
    FROM dbo.Appointments a
    WHERE a.notes LIKE N'BULK-SEED CHECKEDIN #%'
      AND NOT EXISTS (
          SELECT 1 FROM dbo.Visits v WHERE v.appointment_id = a.appointment_id
      );

    INSERT INTO dbo.MedicalRecords (visit_id, veterinarian_id, diagnosis, treatment, note, created_at)
    SELECT
        v.visit_id,
        COALESCE(v.veterinarian_id, @FallbackVetId),
        CASE v.visit_id % 5
            WHEN 0 THEN N'Canine dermatitis'
            WHEN 1 THEN N'Feline upper respiratory infection'
            WHEN 2 THEN N'Mild gastrointestinal upset'
            WHEN 3 THEN N'Annual wellness evaluation'
            ELSE N'Post-vaccination follow-up'
        END,
        CASE v.visit_id % 5
            WHEN 0 THEN N'Topical anti-inflammatory and skin hygiene plan.'
            WHEN 1 THEN N'Supportive care and hydration guidance.'
            WHEN 2 THEN N'Diet adjustment and probiotic support.'
            WHEN 3 THEN N'Preventive counseling, no acute intervention.'
            ELSE N'Observation and home care instructions.'
        END,
        CONCAT(N'BULK-SEED RECORD #', v.visit_id),
        GETDATE()
    FROM dbo.Visits v
    JOIN dbo.Appointments a ON a.appointment_id = v.appointment_id
    WHERE v.visit_status = 'Completed'
      AND a.notes LIKE N'BULK-SEED COMPLETED #%'
      AND NOT EXISTS (
          SELECT 1 FROM dbo.MedicalRecords mr WHERE mr.visit_id = v.visit_id
      );

    INSERT INTO dbo.MedicalRecordServices (record_id, service_id, quantity, price)
    SELECT
        mr.record_id,
        sp.service_id,
        1 + (mr.record_id % 2),
        sp.price
    FROM dbo.MedicalRecords mr
    JOIN dbo.Visits v ON v.visit_id = mr.visit_id
    JOIN dbo.Appointments a ON a.appointment_id = v.appointment_id
    JOIN @ServicePool sp ON sp.rn = ((mr.record_id - 1) % @ServiceCount) + 1
    LEFT JOIN dbo.MedicalRecordServices mrs ON mrs.record_id = mr.record_id
    WHERE a.notes LIKE N'BULK-SEED COMPLETED #%'
      AND mrs.record_id IS NULL;

    INSERT INTO dbo.Prescriptions (record_id, medicine_name, dosage, duration)
    SELECT
        mr.record_id,
        CASE (mr.record_id % 4)
            WHEN 0 THEN N'Amoxicillin'
            WHEN 1 THEN N'Probiotic Paste'
            WHEN 2 THEN N'Antihistamine'
            ELSE N'Omega-3 Supplement'
        END,
        CASE (mr.record_id % 4)
            WHEN 0 THEN N'250 mg twice daily'
            WHEN 1 THEN N'5 ml once daily'
            WHEN 2 THEN N'1 tablet once daily'
            ELSE N'1 capsule once daily'
        END,
        CASE (mr.record_id % 4)
            WHEN 0 THEN N'7 days'
            WHEN 1 THEN N'5 days'
            WHEN 2 THEN N'10 days'
            ELSE N'14 days'
        END
    FROM dbo.MedicalRecords mr
    JOIN dbo.Visits v ON v.visit_id = mr.visit_id
    JOIN dbo.Appointments a ON a.appointment_id = v.appointment_id
    LEFT JOIN dbo.Prescriptions p ON p.record_id = mr.record_id
    WHERE a.notes LIKE N'BULK-SEED COMPLETED #%'
      AND p.record_id IS NULL;

    INSERT INTO dbo.Invoices (visit_id, total_amount, status, created_at)
    SELECT
        mr.visit_id,
        ISNULL(SUM(mrs.price * ISNULL(mrs.quantity, 1)), 0),
        CASE WHEN mr.record_id % 3 = 0 THEN 'Recorded' ELSE 'Paid' END,
        GETDATE()
    FROM dbo.MedicalRecords mr
    JOIN dbo.Visits v ON v.visit_id = mr.visit_id
    JOIN dbo.Appointments a ON a.appointment_id = v.appointment_id
    LEFT JOIN dbo.MedicalRecordServices mrs ON mrs.record_id = mr.record_id
    LEFT JOIN dbo.Invoices i ON i.visit_id = mr.visit_id
    WHERE a.notes LIKE N'BULK-SEED COMPLETED #%'
      AND i.invoice_id IS NULL
    GROUP BY mr.visit_id, mr.record_id;

    INSERT INTO dbo.InvoiceItems (invoice_id, item_type, ref_id, name_snapshot, unit_price, quantity, total_price)
    SELECT
        i.invoice_id,
        N'Service',
        mrs.service_id,
        s.name,
        mrs.price,
        mrs.quantity,
        mrs.price * ISNULL(mrs.quantity, 1)
    FROM dbo.Invoices i
    JOIN dbo.Visits v ON v.visit_id = i.visit_id
    JOIN dbo.Appointments a ON a.appointment_id = v.appointment_id
    JOIN dbo.MedicalRecords mr ON mr.visit_id = v.visit_id
    JOIN dbo.MedicalRecordServices mrs ON mrs.record_id = mr.record_id
    JOIN dbo.Services s ON s.service_id = mrs.service_id
    LEFT JOIN dbo.InvoiceItems ii ON ii.invoice_id = i.invoice_id
    WHERE a.notes LIKE N'BULK-SEED COMPLETED #%'
      AND ii.item_id IS NULL;

    IF @LabTestCount > 0
    BEGIN
        DECLARE @LabTestPool TABLE (
            rn INT IDENTITY(1,1),
            test_id INT
        );

        INSERT INTO @LabTestPool (test_id)
        SELECT test_id
        FROM dbo.LabTests
        ORDER BY test_id;

        INSERT INTO dbo.LabTestRequests (visit_id, test_id, veterinarian_id, request_time, status)
        SELECT TOP (12)
            v.visit_id,
            ltp.test_id,
            COALESCE(v.veterinarian_id, @FallbackVetId),
            DATEADD(minute, 15, ISNULL(v.check_in_time, GETDATE())),
            CASE WHEN v.visit_id % 2 = 0 THEN 'Completed' ELSE 'Pending' END
        FROM dbo.Visits v
        JOIN dbo.Appointments a ON a.appointment_id = v.appointment_id
        JOIN @LabTestPool ltp ON ltp.rn = ((v.visit_id - 1) % @LabTestCount) + 1
        LEFT JOIN dbo.LabTestRequests lr ON lr.visit_id = v.visit_id
        WHERE a.notes LIKE N'BULK-SEED COMPLETED #%'
          AND lr.request_id IS NULL
        ORDER BY v.visit_id DESC;

        INSERT INTO dbo.LabTestResults (request_id, result_value, result_note, result_file, result_date, lab_staff_id)
        SELECT
            lr.request_id,
            CASE WHEN lr.request_id % 3 = 0 THEN N'Slightly elevated' ELSE N'Within normal range' END,
            N'Bulk-seeded lab result for testing dashboards.',
            CONCAT(N'lab_result_', lr.request_id, N'.pdf'),
            DATEADD(hour, 2, ISNULL(lr.request_time, GETDATE())),
            @DefaultLabStaffId
        FROM dbo.LabTestRequests lr
        LEFT JOIN dbo.LabTestResults ltr ON ltr.request_id = lr.request_id
        WHERE lr.status = 'Completed'
          AND ltr.result_id IS NULL;
    END

    INSERT INTO dbo.Notifications (user_id, title, message, created_at)
    SELECT
        u.user_id,
        N'Demo Appointment Created',
        N'Your profile now has additional appointments and medical history for demo testing.',
        GETDATE()
    FROM dbo.Users u
    WHERE u.email LIKE 'demo.customer%@anipats.com'
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.Notifications n
          WHERE n.user_id = u.user_id
            AND n.title = N'Demo Appointment Created'
      );

    PRINT 'Bulk demo data inserted.';
END
ELSE
BEGIN
    PRINT 'Skipped bulk demo data because Veterinarians or Services are missing.';
END
GO

/* =====================================================================
   APPOINTMENT <-> SERVICE NORMALIZATION
   Drop appointments.service_id and use appointment_service bridge table.
   ===================================================================== */
USE [VetClinicManagement1]
GO

IF OBJECT_ID('dbo.appointment_service', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.appointment_service (
        id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        appointment_id INT NOT NULL,
        service_id INT NOT NULL
    );
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_appointment_service_appointments'
      AND parent_object_id = OBJECT_ID('dbo.appointment_service')
)
BEGIN
    ALTER TABLE dbo.appointment_service
    ADD CONSTRAINT FK_appointment_service_appointments
    FOREIGN KEY (appointment_id) REFERENCES dbo.Appointments(appointment_id);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_appointment_service_services'
      AND parent_object_id = OBJECT_ID('dbo.appointment_service')
)
BEGIN
    ALTER TABLE dbo.appointment_service
    ADD CONSTRAINT FK_appointment_service_services
    FOREIGN KEY (service_id) REFERENCES dbo.Services(service_id);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.appointment_service')
      AND name = 'UQ_appointment_service_appointment_service'
)
BEGIN
    CREATE UNIQUE INDEX UQ_appointment_service_appointment_service
    ON dbo.appointment_service (appointment_id, service_id);
END
GO

IF COL_LENGTH('dbo.Appointments', 'service_id') IS NOT NULL
BEGIN
    INSERT INTO dbo.appointment_service (appointment_id, service_id)
    SELECT a.appointment_id, a.service_id
    FROM dbo.Appointments a
    WHERE a.service_id IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.appointment_service aps
          WHERE aps.appointment_id = a.appointment_id
            AND aps.service_id = a.service_id
      );

    IF EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'fk_appointments_service'
          AND parent_object_id = OBJECT_ID('dbo.Appointments')
    )
    BEGIN
        ALTER TABLE dbo.Appointments DROP CONSTRAINT fk_appointments_service;
    END

    ALTER TABLE dbo.Appointments DROP COLUMN service_id;
END
GO

PRINT 'Applied migration: appointments.service_id removed, appointment_service created.';
GO

PRINT 'VetClinicManagement1 schema + full seed data completed successfully.';
GO
