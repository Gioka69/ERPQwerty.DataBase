USE erpqwerty;
GO

-- =============================================
-- 1. Tabla Principal: ConstanciaSituacionFiscal
-- =============================================
PRINT 'Creando Tabla [ConstanciaSituacionFiscal]...';
IF OBJECT_ID(N'[ConstanciaSituacionFiscal]', N'U') IS NULL
BEGIN
    CREATE TABLE [ConstanciaSituacionFiscal] (
        [IdConstanciaSituacionFiscal] int IDENTITY(1,1) NOT NULL,
        
        -- Relación con el Contribuyente (FK)
        [IdContribuyente] int NOT NULL,
        
        -- Datos Generales Extraídos
        [Rfc] nvarchar(13) NULL,
        [Curp] nvarchar(18) NULL,
        [NombreCompleto] nvarchar(255) NULL,
        [CodigoPostal] nvarchar(10) NULL,
        
        -- Fechas de Control
        [FechaDescarga] datetime2(7) NOT NULL, -- Cuándo se bajó el PDF
        [FechaVigencia] datetime2(7) NOT NULL, -- FechaDescarga + 29 días
        [FechaRegistro] datetime2(7) DEFAULT GETUTCDATE(),

        CONSTRAINT [PK_ConstanciaSituacionFiscal] PRIMARY KEY ([IdConstanciaSituacionFiscal]),
        
        -- FK con borrado en cascada: Si se borra el contribuyente, se borran sus constancias.
        CONSTRAINT [FK_ConstanciaSituacionFiscal_Contribuyentes_IdContribuyente] 
            FOREIGN KEY ([IdContribuyente]) REFERENCES [Contribuyentes] ([IdContribuyente]) 
            ON DELETE CASCADE
    );
END
GO

-- =============================================
-- 2. Tabla Detalle: RegimenesConstancia
-- =============================================
PRINT 'Creando Tabla [RegimenesConstancia]...';
IF OBJECT_ID(N'[RegimenesConstancia]', N'U') IS NULL
BEGIN
    CREATE TABLE [RegimenesConstancia] (
        [IdRegimenConstancia] int IDENTITY(1,1) NOT NULL,
        [IdConstanciaSituacionFiscal] int NOT NULL,
        
        [Regimen] nvarchar(max) NOT NULL,
        [FechaInicio] nvarchar(50) NULL, -- Se guarda como string tal cual viene del PDF para evitar errores de parseo
		[FechaFin] nvarchar(50) NULL,


        CONSTRAINT [PK_RegimenesConstancia] PRIMARY KEY ([IdRegimenConstancia]),
        
        CONSTRAINT [FK_RegimenesConstancia_ConstanciaSituacionFiscal] 
            FOREIGN KEY ([IdConstanciaSituacionFiscal]) REFERENCES [ConstanciaSituacionFiscal] ([IdConstanciaSituacionFiscal]) 
            ON DELETE CASCADE
    );
END
GO

-- =============================================
-- 3. Tabla Detalle: ObligacionesConstancia
-- =============================================
PRINT 'Creando Tabla [ObligacionesConstancia]...';
IF OBJECT_ID(N'[ObligacionesConstancia]', N'U') IS NULL
BEGIN
    CREATE TABLE [ObligacionesConstancia] (
        [IdObligacionConstancia] int IDENTITY(1,1) NOT NULL,
        [IdConstanciaSituacionFiscal] int NOT NULL,
        
        [Descripcion] nvarchar(max) NOT NULL,
        [DescripcionVencimiento] nvarchar(max) NULL,
        [FechaInicio] nvarchar(50) NULL,
		[FechaFin] nvarchar(50) NULL,

        CONSTRAINT [PK_ObligacionesConstancia] PRIMARY KEY ([IdObligacionConstancia]),
        
        CONSTRAINT [FK_ObligacionesConstancia_ConstanciaSituacionFiscal] 
            FOREIGN KEY ([IdConstanciaSituacionFiscal]) REFERENCES [ConstanciaSituacionFiscal] ([IdConstanciaSituacionFiscal]) 
            ON DELETE CASCADE
    );
END
GO

-- =============================================
-- 4. Tabla Detalle: ActividadesEconomicasConstancia
-- =============================================
PRINT 'Creando Tabla [ActividadesEconomicasConstancia]...';
IF OBJECT_ID(N'[ActividadesEconomicasConstancia]', N'U') IS NULL
BEGIN
    CREATE TABLE [ActividadesEconomicasConstancia] (
        [IdActividadEconomicaConstancia] int IDENTITY(1,1) NOT NULL,
        [IdConstanciaSituacionFiscal] int NOT NULL,
        
		[Orden] int NOT NULL,
        [Descripcion] nvarchar(max) NOT NULL,
        [Porcentaje] nvarchar(50) NULL,
        [FechaInicio] nvarchar(50) NULL,
        [FechaFin] nvarchar(50) NULL,

        CONSTRAINT [PK_ActividadesEconomicasConstancia] PRIMARY KEY ([IdActividadEconomicaConstancia]),
        
        CONSTRAINT [FK_ActividadesEconomicasConstancia_ConstanciaSituacionFiscal] 
            FOREIGN KEY ([IdConstanciaSituacionFiscal]) REFERENCES [ConstanciaSituacionFiscal] ([IdConstanciaSituacionFiscal]) 
            ON DELETE CASCADE
    );
END
GO

PRINT 'Tablas Fiscales creadas correctamente.';