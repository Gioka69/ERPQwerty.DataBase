USE erpqwerty
GO
-- Script SQL con IDs personalizados (IdUser, IdRole, etc.) en lugar de "Id" genérico.

-- =============================================
-- 1. Tabla de Organizaciones
-- =============================================
PRINT 'Creando Tabla [Organizaciones]...';
IF OBJECT_ID(N'[Organizaciones]', N'U') IS NULL
BEGIN
    CREATE TABLE [Organizaciones] (
        [IdOrganizacion] int IDENTITY(1,1) NOT NULL,
        [NombreOrganizacion] nvarchar(255) NOT NULL,
        [MaxUsuariosPermitidos] int NOT NULL DEFAULT 1, 
        [FechaRegistro] datetime2 NOT NULL DEFAULT GETDATE(), 
        CONSTRAINT [PK_Organizaciones] PRIMARY KEY ([IdOrganizacion])
    );
END
GO

-- =============================================
-- 2. Tablas de ASP.NET Identity (Personalizadas)
-- =============================================
PRINT 'Creando Tabla [AspNetUsers]...';
IF OBJECT_ID(N'[AspNetUsers]', N'U') IS NULL
BEGIN
    CREATE TABLE [AspNetUsers] (
        -- CAMBIO: De [Id] a [IdUser]
        [IdUser] nvarchar(450) NOT NULL, 
        [IdOrganizacion] int NULL,
        
        [UserName] nvarchar(256) NULL,
        [NormalizedUserName] nvarchar(256) NULL,
        [Email] nvarchar(256) NULL,
        [NormalizedEmail] nvarchar(256) NULL,
        [EmailConfirmed] bit NOT NULL,
        [PasswordHash] nvarchar(max) NULL,
        [SecurityStamp] nvarchar(max) NULL,
        [ConcurrencyStamp] nvarchar(max) NULL,
        [PhoneNumber] nvarchar(max) NULL,
        [PhoneNumberConfirmed] bit NOT NULL,
        [TwoFactorEnabled] bit NOT NULL,
        [LockoutEnd] datetimeoffset NULL,
        [LockoutEnabled] bit NOT NULL,
        [AccessFailedCount] int NOT NULL,
        
        CONSTRAINT [PK_AspNetUsers] PRIMARY KEY ([IdUser]),
        CONSTRAINT [FK_AspNetUsers_Organizaciones_IdOrganizacion] FOREIGN KEY ([IdOrganizacion]) 
            REFERENCES [Organizaciones] ([IdOrganizacion]) 
            ON DELETE SET NULL
    );
END
GO

PRINT 'Creando Tablas de Roles y Claims...';

-- Roles
IF OBJECT_ID(N'[AspNetRoles]', N'U') IS NULL
BEGIN
    CREATE TABLE [AspNetRoles] (
        -- CAMBIO: De [Id] a [IdRole]
        [IdRole] nvarchar(450) NOT NULL,
        [Name] nvarchar(256) NULL,
        [NormalizedName] nvarchar(256) NULL,
        [ConcurrencyStamp] nvarchar(max) NULL,
        CONSTRAINT [PK_AspNetRoles] PRIMARY KEY ([IdRole])
    );
END

-- UserClaims
IF OBJECT_ID(N'[AspNetUserClaims]', N'U') IS NULL
BEGIN
    CREATE TABLE [AspNetUserClaims] (
        -- CAMBIO: De [Id] a [IdUserClaim]
        [IdUserClaim] int IDENTITY(1,1) NOT NULL,
        [UserId] nvarchar(450) NOT NULL,
        [ClaimType] nvarchar(max) NULL,
        [ClaimValue] nvarchar(max) NULL,
        CONSTRAINT [PK_AspNetUserClaims] PRIMARY KEY ([IdUserClaim]),
        -- FK apunta a IdUser
        CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([IdUser]) ON DELETE CASCADE
    );
END

-- UserLogins
IF OBJECT_ID(N'[AspNetUserLogins]', N'U') IS NULL
BEGIN
    CREATE TABLE [AspNetUserLogins] (
        [LoginProvider] nvarchar(450) NOT NULL,
        [ProviderKey] nvarchar(450) NOT NULL,
        [ProviderDisplayName] nvarchar(max) NULL,
        [UserId] nvarchar(450) NOT NULL,
        CONSTRAINT [PK_AspNetUserLogins] PRIMARY KEY ([LoginProvider], [ProviderKey]),
        -- FK apunta a IdUser
        CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([IdUser]) ON DELETE CASCADE
    );
END

-- UserRoles
IF OBJECT_ID(N'[AspNetUserRoles]', N'U') IS NULL
BEGIN
    CREATE TABLE [AspNetUserRoles] (
        [UserId] nvarchar(450) NOT NULL,
        [RoleId] nvarchar(450) NOT NULL,
        CONSTRAINT [PK_AspNetUserRoles] PRIMARY KEY ([UserId], [RoleId]),
        -- FKs apuntan a IdRole y IdUser
        CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [AspNetRoles] ([IdRole]) ON DELETE CASCADE,
        CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([IdUser]) ON DELETE CASCADE
    );
END

-- UserTokens
IF OBJECT_ID(N'[AspNetUserTokens]', N'U') IS NULL
BEGIN
    CREATE TABLE [AspNetUserTokens] (
        [UserId] nvarchar(450) NOT NULL,
        [LoginProvider] nvarchar(450) NOT NULL,
        [Name] nvarchar(450) NOT NULL,
        [Value] nvarchar(max) NULL,
        CONSTRAINT [PK_AspNetUserTokens] PRIMARY KEY ([UserId], [LoginProvider], [Name]),
        -- FK apunta a IdUser
        CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([IdUser]) ON DELETE CASCADE
    );
END

-- RoleClaims
IF OBJECT_ID(N'[AspNetRoleClaims]', N'U') IS NULL
BEGIN
    CREATE TABLE [AspNetRoleClaims] (
        -- CAMBIO: De [Id] a [IdRoleClaim]
        [IdRoleClaim] int IDENTITY(1,1) NOT NULL,
        [RoleId] nvarchar(450) NOT NULL,
        [ClaimType] nvarchar(max) NULL,
        [ClaimValue] nvarchar(max) NULL,
        CONSTRAINT [PK_AspNetRoleClaims] PRIMARY KEY ([IdRoleClaim]),
        -- FK apunta a IdRole
        CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [AspNetRoles] ([IdRole]) ON DELETE CASCADE
    );
END
GO

-- =============================================
-- 3. Tabla de Contribuyentes (Actualizada)
-- =============================================
PRINT 'Creando Tabla [Contribuyentes]...';
IF OBJECT_ID(N'[Contribuyentes]', N'U') IS NULL
BEGIN
    CREATE TABLE [Contribuyentes] (
        [IdContribuyente] int IDENTITY(1,1) NOT NULL,
        
        -- Datos Fiscales
        [Rfc] nvarchar(13) NOT NULL, 
        [NombreCompleto] nvarchar(255) NOT NULL,
        [Email] nvarchar(100) NOT NULL, 
        [Telefono] nvarchar(max) NULL,
        
        -- Domicilio
        [Direccion] nvarchar(max) NULL,
        [CodigoPostal] nvarchar(10) NULL,
        [Colonia] nvarchar(255) NULL,
        [Ciudad] nvarchar(255) NULL,
        [Estado] nvarchar(255) NULL,
        [Pais] nvarchar(255) NULL,
        
        -- Archivos FIEL
        [FileCerContent] varbinary(max) NULL,
        [FileKeyContent] varbinary(max) NULL,
        [ContrasenaSatHash] nvarchar(max) NULL,
        
        -- RELACIONES
        [ApplicationUserId] nvarchar(450) NOT NULL, -- Usuario dueño
        
        -- NUEVO CAMPO: IdOrganizacion
        [IdOrganizacion] int NOT NULL, -- Obligatorio: Un contribuyente debe pertenecer a una org

        CONSTRAINT [PK_Contribuyentes] PRIMARY KEY ([IdContribuyente]),
        
        -- FK Usuario
        CONSTRAINT [FK_Contribuyentes_AspNetUsers_ApplicationUserId] FOREIGN KEY ([ApplicationUserId]) 
            REFERENCES [AspNetUsers] ([IdUser]) 
            ON DELETE CASCADE,

        -- FK Organización (NUEVA)
        CONSTRAINT [FK_Contribuyentes_Organizaciones_IdOrganizacion] FOREIGN KEY ([IdOrganizacion]) 
            REFERENCES [Organizaciones] ([IdOrganizacion]) 
            ON DELETE NO ACTION, -- O CASCADE, si borras la org se borran los contribuyentes

        CONSTRAINT [UQ_Contribuyentes_Rfc] UNIQUE ([Rfc])
    );
    
    -- Índice para búsquedas rápidas por Organización (Vital para tu filtro)
    CREATE INDEX [IX_Contribuyentes_IdOrganizacion] ON [Contribuyentes] ([IdOrganizacion]);
END
GO

-- =============================================
-- 4. Índices
-- =============================================
PRINT 'Creando Índices...';

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Contribuyentes_ApplicationUserId' AND object_id = OBJECT_ID('Contribuyentes'))
BEGIN
    CREATE INDEX [IX_Contribuyentes_ApplicationUserId] ON [Contribuyentes] ([ApplicationUserId]);
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AspNetUsers_IdOrganizacion' AND object_id = OBJECT_ID('AspNetUsers'))
BEGIN
    CREATE INDEX [IX_AspNetUsers_IdOrganizacion] ON [AspNetUsers] ([IdOrganizacion]);
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'EmailIndex' AND object_id = OBJECT_ID('AspNetUsers'))
    CREATE INDEX [EmailIndex] ON [AspNetUsers] ([NormalizedEmail]);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UserNameIndex' AND object_id = OBJECT_ID('AspNetUsers'))
    CREATE UNIQUE INDEX [UserNameIndex] ON [AspNetUsers] ([NormalizedUserName]) WHERE [NormalizedUserName] IS NOT NULL;

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'RoleNameIndex' AND object_id = OBJECT_ID('AspNetRoles'))
    CREATE UNIQUE INDEX [RoleNameIndex] ON [AspNetRoles] ([NormalizedName]) WHERE [NormalizedName] IS NOT NULL;

PRINT '¡Base de datos con IDs personalizados creada correctamente!';
GO