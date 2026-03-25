USE [master]
GO
IF DB_ID(N'VetClinicManagement') IS NOT NULL
BEGIN
    ALTER DATABASE [VetClinicManagement] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [VetClinicManagement];
END
GO
CREATE DATABASE [VetClinicManagement]
GO
ALTER DATABASE [VetClinicManagement] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [VetClinicManagement].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [VetClinicManagement] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [VetClinicManagement] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [VetClinicManagement] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [VetClinicManagement] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [VetClinicManagement] SET ARITHABORT OFF 
GO
ALTER DATABASE [VetClinicManagement] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [VetClinicManagement] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [VetClinicManagement] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [VetClinicManagement] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [VetClinicManagement] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [VetClinicManagement] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [VetClinicManagement] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [VetClinicManagement] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [VetClinicManagement] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [VetClinicManagement] SET  ENABLE_BROKER 
GO
ALTER DATABASE [VetClinicManagement] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [VetClinicManagement] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [VetClinicManagement] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [VetClinicManagement] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [VetClinicManagement] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [VetClinicManagement] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [VetClinicManagement] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [VetClinicManagement] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [VetClinicManagement] SET  MULTI_USER 
GO
ALTER DATABASE [VetClinicManagement] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [VetClinicManagement] SET DB_CHAINING OFF 
GO
ALTER DATABASE [VetClinicManagement] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [VetClinicManagement] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [VetClinicManagement] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [VetClinicManagement] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [VetClinicManagement] SET QUERY_STORE = ON
GO
ALTER DATABASE [VetClinicManagement] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [VetClinicManagement]
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
	[conclusion] [nvarchar](500) NULL,
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
	[photoUrl] [nvarchar](500) NULL,
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

/****** Object:  Index [UQ_Users_Phone] ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Users_Phone] ON [dbo].[Users]
(
    [phone] ASC
)
WHERE [phone] IS NOT NULL AND [phone] <> '';
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
ALTER TABLE [dbo].[Visits]  WITH CHECK ADD  CONSxTRAINT [FK_Visits_Vets] FOREIGN KEY([veterinarian_id])
REFERENCES [dbo].[Veterinarians] ([veterinarian_id])
GO
ALTER TABLE [dbo].[Visits] CHECK CONSTRAINT [FK_Visits_Vets]
GO
fiGO
ALTER DATABASE [VetClinicManagement] SET  READ_WRITE 
GO

/* ============================================================
   Bước 1: Normalize & clean schema
   ============================================================ */
USE [VetClinicManagement]
GO

IF COL_LENGTH('dbo.MedicalRecords', 'clinical_condition') IS NULL
BEGIN
    ALTER TABLE dbo.MedicalRecords ADD clinical_condition NVARCHAR(40) NULL;
END
GO

UPDATE dbo.MedicalRecords
SET clinical_condition = N'follow_up'
WHERE clinical_condition IS NULL;
GO

IF COL_LENGTH('dbo.Appointments', 'arrival_time') IS NULL
BEGIN
    ALTER TABLE dbo.Appointments ADD arrival_time DATETIME NULL;
END
GO

IF COL_LENGTH('dbo.Services', 'category') IS NULL
BEGIN
    ALTER TABLE dbo.Services ADD category NVARCHAR(100) NULL;
END
GO

UPDATE dbo.Services
SET category = 'general'
WHERE category IS NULL OR LTRIM(RTRIM(category)) = '';
GO

IF EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_Services_Category'
      AND parent_object_id = OBJECT_ID('dbo.Services')
)
BEGIN
    ALTER TABLE dbo.Services DROP CONSTRAINT CK_Services_Category;
END
GO

ALTER TABLE dbo.Services
ADD CONSTRAINT CK_Services_Category
CHECK (LOWER(LTRIM(RTRIM(category))) IN ('general', 'labtest'));
GO

IF EXISTS (
    SELECT 1
    FROM sys.default_constraints dc
    JOIN sys.columns c
      ON c.object_id = dc.parent_object_id
     AND c.column_id = dc.parent_column_id
    WHERE dc.parent_object_id = OBJECT_ID('dbo.Services')
      AND c.name = 'category'
      AND dc.name = 'DF_Services_Category'
)
BEGIN
    ALTER TABLE dbo.Services DROP CONSTRAINT DF_Services_Category;
END
GO

ALTER TABLE dbo.Services
ADD CONSTRAINT DF_Services_Category DEFAULT ('general') FOR category;
GO

IF COL_LENGTH('dbo.Services', 'duration') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Services DROP COLUMN duration;
END
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'LabTestResults' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    ALTER TABLE dbo.LabTestResults ALTER COLUMN result_note NVARCHAR(MAX) NULL;
END
GO

IF COL_LENGTH('dbo.LabTestResults', 'result_file') IS NULL
BEGIN
    ALTER TABLE dbo.LabTestResults ADD result_file NVARCHAR(500) NULL;
END
GO

IF COL_LENGTH('dbo.LabTestResults', 'result_value') IS NOT NULL
BEGIN
    ALTER TABLE dbo.LabTestResults DROP COLUMN result_value;
END
GO

IF COL_LENGTH('dbo.LabTests', 'description') IS NOT NULL
BEGIN
    ALTER TABLE dbo.LabTests DROP COLUMN description;
END
GO
IF COL_LENGTH('dbo.LabTests', 'normal_range') IS NOT NULL
BEGIN
    ALTER TABLE dbo.LabTests DROP COLUMN normal_range;
END
GO
IF COL_LENGTH('dbo.LabTests', 'unit') IS NOT NULL
BEGIN
    ALTER TABLE dbo.LabTests DROP COLUMN unit;
END
GO

UPDATE dbo.LabTests
SET status = 'Active'
WHERE status IS NULL OR LTRIM(RTRIM(status)) = '';
GO

/* ============================================================
   Bước 2: Generate CREATE TABLE
   -> Done above in original schema section.

   Bước 3: Generate constraints
   -> Done above in original FK ALTER TABLE section + normalize constraints.
   ============================================================ */

/* ============================================================
   Bước 4: Generate seed data
   ============================================================ */
INSERT INTO Roles (role_name) VALUES ('Customer');
INSERT INTO Roles (role_name) VALUES ('Veterinarian');
INSERT INTO Roles (role_name) VALUES ('Receptionist');
INSERT INTO Roles (role_name) VALUES ('LabStaff');
INSERT INTO Roles (role_name) VALUES ('Admin');
INSERT INTO Roles (role_name) VALUES ('ClinicOwner');
GO

INSERT INTO Users (email, password, role_id, status, full_name, phone, address)
VALUES
('dev@anipats.com', '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b', (SELECT role_id FROM Roles WHERE role_name = 'Customer'), 'Active', 'Alex Johnson', '+1 (555) 100-2001', '123 Pet Lane, New York, NY'),
('mary.wilson@email.com', '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b', (SELECT role_id FROM Roles WHERE role_name = 'Customer'), 'Active', 'Mary Wilson', '+1 (555) 100-2002', '456 Oak St, Brooklyn, NY'),
('dr.smith@anipats.com', '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b', (SELECT role_id FROM Roles WHERE role_name = 'Veterinarian'), 'Active', 'Dr. Sarah Smith', '+1 (555) 200-3001', NULL),
('dr.james@anipats.com', '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b', (SELECT role_id FROM Roles WHERE role_name = 'Veterinarian'), 'Active', 'Dr. James Lee', '+1 (555) 200-3002', NULL),
('reception@anipats.com', '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b', (SELECT role_id FROM Roles WHERE role_name = 'Receptionist'), 'Active', 'Emma Davis', '+1 (555) 300-4001', NULL),
('lab@anipats.com', '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b', (SELECT role_id FROM Roles WHERE role_name = 'LabStaff'), 'Active', 'Chris Brown', '+1 (555) 400-5001', NULL),
('admin@anipats.com', '87274af01876341455b32d805946f272871bb42effa6604dccf28bb027afa82b', (SELECT role_id FROM Roles WHERE role_name = 'Admin'), 'Active', 'Admin User', '+1 (555) 000-0001', NULL);
GO

INSERT INTO Customers (user_id) SELECT user_id FROM Users WHERE email = 'dev@anipats.com';
INSERT INTO Customers (user_id) SELECT user_id FROM Users WHERE email = 'mary.wilson@email.com';
INSERT INTO Veterinarians (user_id, specialization) SELECT user_id, 'General Practice' FROM Users WHERE email = 'dr.smith@anipats.com';
INSERT INTO Veterinarians (user_id, specialization) SELECT user_id, 'Surgery' FROM Users WHERE email = 'dr.james@anipats.com';
INSERT INTO Receptionists (user_id) SELECT user_id FROM Users WHERE email = 'reception@anipats.com';
INSERT INTO LabStaff (user_id, position) SELECT user_id, 'Lab Technician' FROM Users WHERE email = 'lab@anipats.com';
GO

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

INSERT INTO Services (name, price, description, category) VALUES
('General Checkup', 50.00, 'Routine health examination', 'general'),
('Vaccination', 35.00, 'Core vaccination', 'general'),
('Dental Cleaning', 80.00, 'Teeth cleaning and examination', 'general'),
('Blood Test', 45.00, 'Basic blood panel', 'labtest'),
('X-Ray', 120.00, 'Radiology', 'labtest'),
('Surgery Consultation', 75.00, 'Pre-surgery assessment', 'general'),
('Emergency Visit', 150.00, 'Emergency care', 'general');
GO

INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status, service_id)
SELECT p.pet_id, p.customer_id, v.veterinarian_id, DATEADD(day, -7, GETDATE()), 'Completed', s.service_id
FROM Pets p
CROSS JOIN (SELECT TOP 1 veterinarian_id FROM Veterinarians) v
CROSS JOIN (SELECT TOP 1 service_id FROM Services WHERE name = 'General Checkup') s
JOIN Customers c ON p.customer_id = c.customer_id
JOIN Users u ON c.user_id = u.user_id
WHERE u.email = 'dev@anipats.com' AND p.name = 'Max';

INSERT INTO Appointments (pet_id, customer_id, veterinarian_id, appointment_time, status, service_id)
SELECT p.pet_id, p.customer_id, v.veterinarian_id, DATEADD(day, 3, GETDATE()), 'Scheduled', s.service_id
FROM Pets p
CROSS JOIN (SELECT TOP 1 veterinarian_id FROM Veterinarians) v
CROSS JOIN (SELECT TOP 1 service_id FROM Services WHERE name = 'Vaccination') s
JOIN Customers c ON p.customer_id = c.customer_id
JOIN Users u ON c.user_id = u.user_id
WHERE u.email = 'dev@anipats.com' AND p.name = 'Luna';
GO

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

INSERT INTO MedicalRecords (visit_id, veterinarian_id, diagnosis, conclusion, note, clinical_condition)
SELECT v.visit_id, v.veterinarian_id,
       'Routine checkup - healthy',
       'Vaccination booster administered',
       'Pet in good condition. Next checkup in 1 year.',
       'follow_up'
FROM Visits v
WHERE v.visit_status = 'Completed';
GO

INSERT INTO MedicalRecordServices (record_id, service_id, quantity, price)
SELECT mr.record_id, s.service_id, 1, s.price
FROM MedicalRecords mr
CROSS JOIN (SELECT service_id, price FROM Services WHERE name = 'General Checkup') s;
GO

INSERT INTO Prescriptions (record_id, medicine_name, dosage, duration)
SELECT record_id, 'Flea prevention (monthly)', '1 tablet per month', '12 months'
FROM MedicalRecords;
GO

INSERT INTO LabTests (test_name, status) VALUES
('Complete Blood Count', 'Active'),
('Blood Glucose', 'Active'),
('Kidney Panel', 'Active');
GO

INSERT INTO LabTestRequests (visit_id, test_id, veterinarian_id, status)
SELECT v.visit_id, (SELECT TOP 1 test_id FROM LabTests), v.veterinarian_id, 'Completed'
FROM Visits v
WHERE v.visit_status = 'Completed';
GO

INSERT INTO LabTestResults (request_id, result_note, lab_staff_id)
SELECT ltr.request_id, 'No abnormalities', (SELECT TOP 1 staff_id FROM LabStaff)
FROM LabTestRequests ltr
WHERE ltr.status = 'Completed';
GO

INSERT INTO Invoices (visit_id, total_amount, status)
SELECT v.visit_id, 85.00, 'Paid'
FROM Visits v
WHERE v.visit_status = 'Completed';
GO

INSERT INTO InvoiceItems (invoice_id, item_type, ref_id, name_snapshot, unit_price, quantity, total_price)
SELECT i.invoice_id, 'Service', NULL, 'General Checkup', 50.00, 1, 50.00
FROM Invoices i;
INSERT INTO InvoiceItems (invoice_id, item_type, ref_id, name_snapshot, unit_price, quantity, total_price)
SELECT i.invoice_id, 'Service', NULL, 'Vaccination', 35.00, 1, 35.00
FROM Invoices i;
GO

INSERT INTO Notifications (user_id, title, message)
SELECT u.user_id, 'Appointment Reminder', 'Your appointment for Luna is in 3 days.'
FROM Users u WHERE u.email = 'dev@anipats.com';
INSERT INTO Notifications (user_id, title, message)
SELECT u.user_id, 'Welcome', 'Thank you for choosing Anipats. We care for your pets.'
FROM Users u WHERE u.email = 'mary.wilson@email.com';
GO

INSERT INTO Blogs (title, content, status, author_user_id) VALUES
('5 Signs Your Pet Needs a Checkup', 'Regular vet visits are essential for pet health.', 'Published', (SELECT TOP 1 user_id FROM Users WHERE email = 'admin@anipats.com')),
('Vaccination Schedule for Dogs', 'Core vaccines include rabies, distemper, parvovirus.', 'Published', (SELECT TOP 1 user_id FROM Users WHERE email = 'admin@anipats.com')),
('Dental Care for Cats', 'Dental disease is common in cats. Annual cleaning is recommended.', 'Published', (SELECT TOP 1 user_id FROM Users WHERE email = 'admin@anipats.com'));
GO

/* ============================================================
   Bước 5: Merge final script
   -> This file itself is the final merged one-run script.
   ============================================================ */
PRINT 'Merged script completed successfully.';
PRINT 'Database: VetClinicManagement';
PRINT 'Default login password for sample accounts: dev123';
GO
