-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
-- Knots are unfolded when using equivalence.
--
-- ANCHORS AND ATTRIBUTES ---------------------------------------------------------------------------------------------
--
-- Anchors are used to store the identities of entities.
-- Anchors are immutable.
-- Attributes are used to store values for properties of entities.
-- Attributes are mutable, their values may change over one or more types of time.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
-- Anchors may have zero or more adjoined attributes.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- MD_Model table (with 0 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.MD_Model', 'U') IS NULL
CREATE TABLE [metadata].[MD_Model] (
    MD_ID int IDENTITY(1,1) not null,
    MD_Dummy bit null,
    constraint pkMD_Model primary key (
        MD_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- TM_Term table (with 1 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.TM_Term', 'U') IS NULL
CREATE TABLE [metadata].[TM_Term] (
    TM_ID int IDENTITY(1,1) not null,
    TM_Dummy bit null,
    constraint pkTM_Term primary key (
        TM_ID asc
    )
);
GO
-- Static attribute table ---------------------------------------------------------------------------------------------
-- TM_NAM_Term_Name table (on TM_Term)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.TM_NAM_Term_Name', 'U') IS NULL
CREATE TABLE [metadata].[TM_NAM_Term_Name] (
    TM_NAM_TM_ID int not null,
    TM_NAM_Term_Name varchar(max) not null,
    constraint fkTM_NAM_Term_Name foreign key (
        TM_NAM_TM_ID
    ) references [metadata].[TM_Term](TM_ID),
    constraint pkTM_NAM_Term_Name primary key (
        TM_NAM_TM_ID asc
    )
);
GO
-- Anchor table -------------------------------------------------------------------------------------------------------
-- TB_Table table (with 0 attributes)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.TB_Table', 'U') IS NULL
CREATE TABLE [metadata].[TB_Table] (
    TB_ID int IDENTITY(1,1) not null,
    TB_Dummy bit null,
    constraint pkTB_Table primary key (
        TB_ID asc
    )
);
GO
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- Ties are used to represent relationships between entities.
-- They come in four flavors: static, historized, knotted static, and knotted historized.
-- Ties have cardinality, constraining how members may participate in the relationship.
-- Every entity that is a member in a tie has a specified role in the relationship.
-- Ties must have at least two anchor roles and zero or more knot roles.
--
-- Static tie table ---------------------------------------------------------------------------------------------------
-- MD_has_TM_names table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.MD_has_TM_names', 'U') IS NULL
CREATE TABLE [metadata].[MD_has_TM_names] (
    MD_ID_has int not null, 
    TM_ID_names int not null, 
    constraint MD_has_TM_names_fkMD_has foreign key (
        MD_ID_has
    ) references [metadata].[MD_Model](MD_ID), 
    constraint MD_has_TM_names_fkTM_names foreign key (
        TM_ID_names
    ) references [metadata].[TM_Term](TM_ID), 
    constraint MD_has_TM_names_uqMD_has unique (
        MD_ID_has
    ),
    constraint MD_has_TM_names_uqTM_names unique (
        TM_ID_names
    ),
    constraint pkMD_has_TM_names primary key (
        MD_ID_has asc,
        TM_ID_names asc
    )
);
GO
-- Static tie table ---------------------------------------------------------------------------------------------------
-- TM_names_TB_in_MD_contains table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.TM_names_TB_in_MD_contains', 'U') IS NULL
CREATE TABLE [metadata].[TM_names_TB_in_MD_contains] (
    TM_ID_names int not null, 
    TB_ID_in int not null, 
    MD_ID_contains int not null, 
    constraint TM_names_TB_in_MD_contains_fkTM_names foreign key (
        TM_ID_names
    ) references [metadata].[TM_Term](TM_ID), 
    constraint TM_names_TB_in_MD_contains_fkTB_in foreign key (
        TB_ID_in
    ) references [metadata].[TB_Table](TB_ID), 
    constraint TM_names_TB_in_MD_contains_fkMD_contains foreign key (
        MD_ID_contains
    ) references [metadata].[MD_Model](MD_ID), 
    constraint TM_names_TB_in_MD_contains_uqMD_contains_TM_names unique (
        MD_ID_contains, TM_ID_names
    ),
    constraint TM_names_TB_in_MD_contains_uqTB_in unique (
        TB_ID_in
    ),
    constraint pkTM_names_TB_in_MD_contains primary key (
        TM_ID_names asc,
        TB_ID_in asc,
        MD_ID_contains asc
    )
);
GO
-- KNOT EQUIVALENCE VIEWS ---------------------------------------------------------------------------------------------
--
-- Equivalence views combine the identity and equivalent parts of a knot into a single view, making
-- it look and behave like a regular knot. They also make it possible to retrieve data for only the
-- given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- ATTRIBUTE EQUIVALENCE VIEWS ----------------------------------------------------------------------------------------
--
-- Equivalence views of attributes make it possible to retrieve data for only the given equivalent.
--
-- @equivalent the equivalent that you want to retrieve data for
--
-- KEY GENERATORS -----------------------------------------------------------------------------------------------------
--
-- These stored procedures can be used to generate identities of entities.
-- Corresponding anchors must have an incrementing identity column.
--
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kMD_Model identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.kMD_Model', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [metadata].[kMD_Model] (
        @requestedNumberOfIdentities bigint
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [metadata].[MD_Model] (
                MD_Dummy
            )
            OUTPUT
                inserted.MD_ID
            SELECT
                null
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kTM_Term identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.kTM_Term', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [metadata].[kTM_Term] (
        @requestedNumberOfIdentities bigint
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [metadata].[TM_Term] (
                TM_Dummy
            )
            OUTPUT
                inserted.TM_ID
            SELECT
                null
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- Key Generation Stored Procedure ------------------------------------------------------------------------------------
-- kTB_Table identity by surrogate key generation stored procedure
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.kTB_Table', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE [metadata].[kTB_Table] (
        @requestedNumberOfIdentities bigint
    ) AS
    BEGIN
        SET NOCOUNT ON;
        IF @requestedNumberOfIdentities > 0
        BEGIN
            WITH idGenerator (idNumber) AS (
                SELECT
                    1
                UNION ALL
                SELECT
                    idNumber + 1
                FROM
                    idGenerator
                WHERE
                    idNumber < @requestedNumberOfIdentities
            )
            INSERT INTO [metadata].[TB_Table] (
                TB_Dummy
            )
            OUTPUT
                inserted.TB_ID
            SELECT
                null
            FROM
                idGenerator
            OPTION (maxrecursion 0);
        END
    END
    ');
END
GO
-- ATTRIBUTE REWINDERS ------------------------------------------------------------------------------------------------
--
-- These table valued functions rewind an attribute table to the given
-- point in changing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time.
--
-- @changingTimepoint the point in changing time to rewind to
--
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each anchor. There are four types of perspectives: latest,
-- point-in-time, difference, and now. They also denormalize the anchor, its attributes,
-- and referenced knots from sixth to third normal form.
--
-- The latest perspective shows the latest available information for each anchor.
-- The now perspective shows the information as it is right now.
-- The point-in-time perspective lets you travel through the information to the given timepoint.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints, and for
-- changes in all or a selection of attributes.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
-- @selection a list of mnemonics for tracked attributes, ie 'MNE MON ICS', or null for all
--
-- Under equivalence all these views default to equivalent = 0, however, corresponding
-- prepended-e perspectives are provided in order to select a specific equivalent.
--
-- @equivalent the equivalent for which to retrieve data
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('metadata.dTM_Term', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dTM_Term];
IF Object_ID('metadata.nTM_Term', 'V') IS NOT NULL
DROP VIEW [metadata].[nTM_Term];
IF Object_ID('metadata.pTM_Term', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pTM_Term];
IF Object_ID('metadata.lTM_Term', 'V') IS NOT NULL
DROP VIEW [metadata].[lTM_Term];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lTM_Term viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lTM_Term] WITH SCHEMABINDING AS
SELECT
    [TM].TM_ID,
    [NAM].TM_NAM_TM_ID,
    [NAM].TM_NAM_Term_Name
FROM
    [metadata].[TM_Term] [TM]
LEFT JOIN
    [metadata].[TM_NAM_Term_Name] [NAM]
ON
    [NAM].TM_NAM_TM_ID = [TM].TM_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pTM_Term viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pTM_Term] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [TM].TM_ID,
    [NAM].TM_NAM_TM_ID,
    [NAM].TM_NAM_Term_Name
FROM
    [metadata].[TM_Term] [TM]
LEFT JOIN
    [metadata].[TM_NAM_Term_Name] [NAM]
ON
    [NAM].TM_NAM_TM_ID = [TM].TM_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nTM_Term viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nTM_Term]
AS
SELECT
    *
FROM
    [metadata].[pTM_Term](sysdatetime());
GO
-- ATTRIBUTE TRIGGERS ------------------------------------------------------------------------------------------------
--
-- The following triggers on the attributes make them behave like tables.
-- There is one 'instead of' trigger for: insert.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_TM_NAM_Term_Name instead of INSERT trigger on TM_NAM_Term_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_TM_NAM_Term_Name', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_TM_NAM_Term_Name];
GO
CREATE TRIGGER [metadata].[it_TM_NAM_Term_Name] ON [metadata].[TM_NAM_Term_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @TM_NAM_Term_Name TABLE (
        TM_NAM_TM_ID int not null,
        TM_NAM_Term_Name varchar(max) not null,
        TM_NAM_Version bigint not null,
        TM_NAM_StatementType char(1) not null,
        primary key(
            TM_NAM_Version,
            TM_NAM_TM_ID
        )
    );
    INSERT INTO @TM_NAM_Term_Name
    SELECT
        i.TM_NAM_TM_ID,
        i.TM_NAM_Term_Name,
        ROW_NUMBER() OVER (
            PARTITION BY
                i.TM_NAM_TM_ID
            ORDER BY
                (SELECT 1) ASC -- some undefined order
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = 1,
        @currentVersion = 0
    FROM
        @TM_NAM_Term_Name;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.TM_NAM_StatementType =
                CASE
                    WHEN [NAM].TM_NAM_TM_ID is not null
                    THEN 'D' -- duplicate
                    ELSE 'N' -- new statement
                END
        FROM
            @TM_NAM_Term_Name v
        LEFT JOIN
            [metadata].[TM_NAM_Term_Name] [NAM]
        ON
            [NAM].TM_NAM_TM_ID = v.TM_NAM_TM_ID
        AND
            [NAM].TM_NAM_Term_Name = v.TM_NAM_Term_Name
        WHERE
            v.TM_NAM_Version = @currentVersion;
        INSERT INTO [metadata].[TM_NAM_Term_Name] (
            TM_NAM_TM_ID,
            TM_NAM_Term_Name
        )
        SELECT
            TM_NAM_TM_ID,
            TM_NAM_Term_Name
        FROM
            @TM_NAM_Term_Name
        WHERE
            TM_NAM_Version = @currentVersion
        AND
            TM_NAM_StatementType in ('N');
    END
END
GO
-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lTM_Term instead of INSERT trigger on lTM_Term
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lTM_Term] ON [metadata].[lTM_Term]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @TM TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        TM_ID int not null
    );
    INSERT INTO [metadata].[TM_Term] (
        TM_Dummy
    )
    OUTPUT
        inserted.TM_ID
    INTO
        @TM
    SELECT
        null
    FROM
        inserted
    WHERE
        inserted.TM_ID is null;
    DECLARE @inserted TABLE (
        TM_ID int not null,
        TM_NAM_TM_ID int null,
        TM_NAM_Term_Name varchar(max) null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.TM_ID, a.TM_ID),
        ISNULL(ISNULL(i.TM_NAM_TM_ID, i.TM_ID), a.TM_ID),
        i.TM_NAM_Term_Name
    FROM (
        SELECT
            TM_ID,
            TM_NAM_TM_ID,
            TM_NAM_Term_Name,
            ROW_NUMBER() OVER (PARTITION BY TM_ID ORDER BY TM_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @TM a
    ON
        a.Row = i.Row;
    INSERT INTO [metadata].[TM_NAM_Term_Name] (
        TM_NAM_TM_ID,
        TM_NAM_Term_Name
    )
    SELECT
        i.TM_NAM_TM_ID,
        i.TM_NAM_Term_Name
    FROM
        @inserted i
    WHERE
        i.TM_NAM_Term_Name is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lTM_Term instead of UPDATE trigger on lTM_Term
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[ut_lTM_Term] ON [metadata].[lTM_Term]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    IF(UPDATE(TM_ID))
        RAISERROR('The identity column TM_ID is not updatable.', 16, 1);
    IF(UPDATE(TM_NAM_TM_ID))
        RAISERROR('The foreign key column TM_NAM_TM_ID is not updatable.', 16, 1);
    IF (UPDATE(TM_NAM_Term_Name)) 
        RAISERROR('The static column TM_NAM_Term_Name is not updatable, and your attempt to update it has been ignored.', 0, 1);
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lTM_Term instead of DELETE trigger on lTM_Term
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dt_lTM_Term] ON [metadata].[lTM_Term]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [NAM]
    FROM
        [metadata].[TM_NAM_Term_Name] [NAM]
    JOIN
        deleted d
    ON
        d.TM_NAM_TM_ID = [NAM].TM_NAM_TM_ID;
    DELETE [TM]
    FROM
        [metadata].[TM_Term] [TM]
    LEFT JOIN
        [metadata].[TM_NAM_Term_Name] [NAM]
    ON
        [NAM].TM_NAM_TM_ID = [TM].TM_ID
    WHERE
        [NAM].TM_NAM_TM_ID is null;
END
GO
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each tie. There are four types of perspectives: latest,
-- point-in-time, difference, and now.
--
-- The latest perspective shows the latest available information for each tie.
-- The now perspective shows the information as it is right now.
-- The point-in-time perspective lets you travel through the information to the given timepoint.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
--
-- Under equivalence all these views default to equivalent = 0, however, corresponding
-- prepended-e perspectives are provided in order to select a specific equivalent.
--
-- @equivalent the equivalent for which to retrieve data
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('metadata.dMD_has_TM_names', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dMD_has_TM_names];
IF Object_ID('metadata.nMD_has_TM_names', 'V') IS NOT NULL
DROP VIEW [metadata].[nMD_has_TM_names];
IF Object_ID('metadata.pMD_has_TM_names', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pMD_has_TM_names];
IF Object_ID('metadata.lMD_has_TM_names', 'V') IS NOT NULL
DROP VIEW [metadata].[lMD_has_TM_names];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lMD_has_TM_names viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lMD_has_TM_names] WITH SCHEMABINDING AS
SELECT
    tie.MD_ID_has,
    tie.TM_ID_names
FROM
    [metadata].[MD_has_TM_names] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pMD_has_TM_names viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pMD_has_TM_names] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.MD_ID_has,
    tie.TM_ID_names
FROM
    [metadata].[MD_has_TM_names] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nMD_has_TM_names viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nMD_has_TM_names]
AS
SELECT
    *
FROM
    [metadata].[pMD_has_TM_names](sysdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('metadata.dTM_names_TB_in_MD_contains', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[dTM_names_TB_in_MD_contains];
IF Object_ID('metadata.nTM_names_TB_in_MD_contains', 'V') IS NOT NULL
DROP VIEW [metadata].[nTM_names_TB_in_MD_contains];
IF Object_ID('metadata.pTM_names_TB_in_MD_contains', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[pTM_names_TB_in_MD_contains];
IF Object_ID('metadata.lTM_names_TB_in_MD_contains', 'V') IS NOT NULL
DROP VIEW [metadata].[lTM_names_TB_in_MD_contains];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lTM_names_TB_in_MD_contains viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[lTM_names_TB_in_MD_contains] WITH SCHEMABINDING AS
SELECT
    tie.TM_ID_names,
    tie.TB_ID_in,
    tie.MD_ID_contains
FROM
    [metadata].[TM_names_TB_in_MD_contains] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pTM_names_TB_in_MD_contains viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [metadata].[pTM_names_TB_in_MD_contains] (
    @changingTimepoint datetime2(7)
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.TM_ID_names,
    tie.TB_ID_in,
    tie.MD_ID_contains
FROM
    [metadata].[TM_names_TB_in_MD_contains] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nTM_names_TB_in_MD_contains viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [metadata].[nTM_names_TB_in_MD_contains]
AS
SELECT
    *
FROM
    [metadata].[pTM_names_TB_in_MD_contains](sysdatetime());
GO
-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent ties, only changes that represent values different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_MD_has_TM_names instead of INSERT trigger on MD_has_TM_names
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_MD_has_TM_names', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_MD_has_TM_names];
GO
CREATE TRIGGER [metadata].[it_MD_has_TM_names] ON [metadata].[MD_has_TM_names]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        MD_ID_has int not null,
        TM_ID_names int not null,
        primary key (
            MD_ID_has,
            TM_ID_names
        )
    );
    INSERT INTO @inserted
    SELECT
        i.MD_ID_has,
        i.TM_ID_names
    FROM
        inserted i
    WHERE
        i.MD_ID_has is not null
    AND
        i.TM_ID_names is not null;
    INSERT INTO [metadata].[MD_has_TM_names] (
        MD_ID_has,
        TM_ID_names
    )
    SELECT
        i.MD_ID_has,
        i.TM_ID_names
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[MD_has_TM_names] tie
    ON
        tie.MD_ID_has = i.MD_ID_has
    OR
        tie.TM_ID_names = i.TM_ID_names
    WHERE
        tie.TM_ID_names is null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lMD_has_TM_names instead of INSERT trigger on lMD_has_TM_names
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lMD_has_TM_names] ON [metadata].[lMD_has_TM_names]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    INSERT INTO [metadata].[MD_has_TM_names] (
        MD_ID_has,
        TM_ID_names
    )
    SELECT
        i.MD_ID_has,
        i.TM_ID_names
    FROM
        inserted i;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lMD_has_TM_names instead of UPDATE trigger on lMD_has_TM_names
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[ut_lMD_has_TM_names] ON [metadata].[lMD_has_TM_names]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    INSERT INTO [metadata].[MD_has_TM_names] (
        MD_ID_has,
        TM_ID_names
    )
    SELECT
        i.MD_ID_has,
        i.TM_ID_names
    FROM
        inserted i;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lMD_has_TM_names instead of DELETE trigger on lMD_has_TM_names
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dt_lMD_has_TM_names] ON [metadata].[lMD_has_TM_names]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [metadata].[MD_has_TM_names] tie
    JOIN
        deleted d
    ON
       (
            d.MD_ID_has = tie.MD_ID_has
        OR
            d.TM_ID_names = tie.TM_ID_names
       );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_TM_names_TB_in_MD_contains instead of INSERT trigger on TM_names_TB_in_MD_contains
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata.it_TM_names_TB_in_MD_contains', 'TR') IS NOT NULL
DROP TRIGGER [metadata].[it_TM_names_TB_in_MD_contains];
GO
CREATE TRIGGER [metadata].[it_TM_names_TB_in_MD_contains] ON [metadata].[TM_names_TB_in_MD_contains]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        TM_ID_names int not null,
        TB_ID_in int not null,
        MD_ID_contains int not null,
        primary key (
            TM_ID_names,
            TB_ID_in,
            MD_ID_contains
        )
    );
    INSERT INTO @inserted
    SELECT
        i.TM_ID_names,
        i.TB_ID_in,
        i.MD_ID_contains
    FROM
        inserted i
    WHERE
        i.TM_ID_names is not null
    AND
        i.TB_ID_in is not null
    AND
        i.MD_ID_contains is not null;
    INSERT INTO [metadata].[TM_names_TB_in_MD_contains] (
        TM_ID_names,
        TB_ID_in,
        MD_ID_contains
    )
    SELECT
        i.TM_ID_names,
        i.TB_ID_in,
        i.MD_ID_contains
    FROM
        @inserted i
    LEFT JOIN
        [metadata].[TM_names_TB_in_MD_contains] tie
    ON
        tie.TM_ID_names = i.TM_ID_names
    OR
        tie.TB_ID_in = i.TB_ID_in
    OR
        tie.MD_ID_contains = i.MD_ID_contains
    WHERE
        tie.MD_ID_contains is null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lTM_names_TB_in_MD_contains instead of INSERT trigger on lTM_names_TB_in_MD_contains
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[it_lTM_names_TB_in_MD_contains] ON [metadata].[lTM_names_TB_in_MD_contains]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    INSERT INTO [metadata].[TM_names_TB_in_MD_contains] (
        TM_ID_names,
        TB_ID_in,
        MD_ID_contains
    )
    SELECT
        i.TM_ID_names,
        i.TB_ID_in,
        i.MD_ID_contains
    FROM
        inserted i;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lTM_names_TB_in_MD_contains instead of UPDATE trigger on lTM_names_TB_in_MD_contains
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[ut_lTM_names_TB_in_MD_contains] ON [metadata].[lTM_names_TB_in_MD_contains]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2(7);
    SET @now = sysdatetime();
    INSERT INTO [metadata].[TM_names_TB_in_MD_contains] (
        TM_ID_names,
        TB_ID_in,
        MD_ID_contains
    )
    SELECT
        i.TM_ID_names,
        i.TB_ID_in,
        i.MD_ID_contains
    FROM
        inserted i;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lTM_names_TB_in_MD_contains instead of DELETE trigger on lTM_names_TB_in_MD_contains
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [metadata].[dt_lTM_names_TB_in_MD_contains] ON [metadata].[lTM_names_TB_in_MD_contains]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [metadata].[TM_names_TB_in_MD_contains] tie
    JOIN
        deleted d
    ON
       (
            d.TM_ID_names = tie.TM_ID_names
        OR
            d.TB_ID_in = tie.TB_ID_in
        OR
            d.MD_ID_contains = tie.MD_ID_contains
       );
END
GO
-- SCHEMA EVOLUTION ---------------------------------------------------------------------------------------------------
--
-- The following tables, views, and functions are used to track schema changes
-- over time, as well as providing every XML that has been 'executed' against
-- the database.
--
-- Schema table -------------------------------------------------------------------------------------------------------
-- The schema table holds every xml that has been executed against the database
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Schema', 'U') IS NULL
   CREATE TABLE [metadata].[_Schema] (
      [version] int identity(1, 1) not null,
      [activation] datetime2(7) not null,
      [schema] xml not null,
      constraint pk_Schema primary key (
         [version]
      )
   );
GO
-- Insert the XML schema (as of now)
INSERT INTO [metadata].[_Schema] (
   [activation],
   [schema]
)
SELECT
   current_timestamp,
   N'<schema format="0.99" date="2015-12-14" time="10:12:00"><metadata changingRange="datetime2(7)" encapsulation="metadata" identity="int" metadataPrefix="Metadata" metadataType="int" metadataUsage="false" changingSuffix="ChangedAt" identitySuffix="ID" positIdentity="int" positGenerator="true" positingRange="datetime" positingSuffix="PositedAt" positorRange="smallint" positorSuffix="Positor" reliabilityRange="smallint" reliabilitySuffix="Reliability" deleteReliability="0" assertionSuffix="Assertion" partitioning="false" entityIntegrity="true" restatability="false" idempotency="true" assertiveness="false" naming="improved" positSuffix="Posit" annexSuffix="Annex" chronon="datetime2(7)" now="sysdatetime()" dummySuffix="Dummy" versionSuffix="Version" statementTypeSuffix="StatementType" checksumSuffix="Checksum" businessViews="false" decisiveness="true" equivalence="false" equivalentSuffix="EQ" equivalentRange="smallint" databaseTarget="SQLServer" temporalization="uni"/><anchor mnemonic="MD" descriptor="Model" identity="int"><metadata capsule="metadata" generator="true"/><layout x="655.36" y="500.38" fixed="false"/></anchor><anchor mnemonic="TM" descriptor="Term" identity="int"><metadata capsule="metadata" generator="true"/><attribute mnemonic="NAM" descriptor="Name" dataRange="varchar(max)"><metadata capsule="metadata"/><layout x="684.35" y="468.06" fixed="false"/></attribute><layout x="710.06" y="444.45" fixed="false"/></anchor><anchor mnemonic="TB" descriptor="Table" identity="int"><metadata capsule="metadata" generator="true"/><layout x="593.25" y="374.31" fixed="false"/></anchor><tie><anchorRole role="has" type="MD" identifier="false"/><anchorRole role="names" type="TM" identifier="false"/><metadata capsule="metadata"/><layout x="755.98" y="506.43" fixed="false"/></tie><tie><anchorRole role="names" type="TM" identifier="false"/><anchorRole role="in" type="TB" identifier="false"/><anchorRole role="contains" type="MD" identifier="false"/><metadata capsule="metadata"/><layout x="619.49" y="430.22" fixed="false"/></tie></schema>';
GO
-- Schema expanded view -----------------------------------------------------------------------------------------------
-- A view of the schema table that expands the XML attributes into columns
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Schema_Expanded', 'V') IS NOT NULL
DROP VIEW [metadata].[_Schema_Expanded]
GO
CREATE VIEW [metadata].[_Schema_Expanded]
AS
SELECT
	[version],
	[activation],
	[schema],
	[schema].value('schema[1]/@format', 'nvarchar(max)') as [format],
	[schema].value('schema[1]/@date', 'datetime') + [schema].value('schema[1]/@time', 'datetime') as [date],
	[schema].value('schema[1]/metadata[1]/@temporalization', 'nvarchar(max)') as [temporalization],
	[schema].value('schema[1]/metadata[1]/@databaseTarget', 'nvarchar(max)') as [databaseTarget],
	[schema].value('schema[1]/metadata[1]/@changingRange', 'nvarchar(max)') as [changingRange],
	[schema].value('schema[1]/metadata[1]/@encapsulation', 'nvarchar(max)') as [encapsulation],
	[schema].value('schema[1]/metadata[1]/@identity', 'nvarchar(max)') as [identity],
	[schema].value('schema[1]/metadata[1]/@metadataPrefix', 'nvarchar(max)') as [metadataPrefix],
	[schema].value('schema[1]/metadata[1]/@metadataType', 'nvarchar(max)') as [metadataType],
	[schema].value('schema[1]/metadata[1]/@metadataUsage', 'nvarchar(max)') as [metadataUsage],
	[schema].value('schema[1]/metadata[1]/@changingSuffix', 'nvarchar(max)') as [changingSuffix],
	[schema].value('schema[1]/metadata[1]/@identitySuffix', 'nvarchar(max)') as [identitySuffix],
	[schema].value('schema[1]/metadata[1]/@positIdentity', 'nvarchar(max)') as [positIdentity],
	[schema].value('schema[1]/metadata[1]/@positGenerator', 'nvarchar(max)') as [positGenerator],
	[schema].value('schema[1]/metadata[1]/@positingRange', 'nvarchar(max)') as [positingRange],
	[schema].value('schema[1]/metadata[1]/@positingSuffix', 'nvarchar(max)') as [positingSuffix],
	[schema].value('schema[1]/metadata[1]/@positorRange', 'nvarchar(max)') as [positorRange],
	[schema].value('schema[1]/metadata[1]/@positorSuffix', 'nvarchar(max)') as [positorSuffix],
	[schema].value('schema[1]/metadata[1]/@reliabilityRange', 'nvarchar(max)') as [reliabilityRange],
	[schema].value('schema[1]/metadata[1]/@reliabilitySuffix', 'nvarchar(max)') as [reliabilitySuffix],
	[schema].value('schema[1]/metadata[1]/@deleteReliability', 'nvarchar(max)') as [deleteReliability],
	[schema].value('schema[1]/metadata[1]/@assertionSuffix', 'nvarchar(max)') as [assertionSuffix],
	[schema].value('schema[1]/metadata[1]/@partitioning', 'nvarchar(max)') as [partitioning],
	[schema].value('schema[1]/metadata[1]/@entityIntegrity', 'nvarchar(max)') as [entityIntegrity],
	[schema].value('schema[1]/metadata[1]/@restatability', 'nvarchar(max)') as [restatability],
	[schema].value('schema[1]/metadata[1]/@idempotency', 'nvarchar(max)') as [idempotency],
	[schema].value('schema[1]/metadata[1]/@assertiveness', 'nvarchar(max)') as [assertiveness],
	[schema].value('schema[1]/metadata[1]/@naming', 'nvarchar(max)') as [naming],
	[schema].value('schema[1]/metadata[1]/@positSuffix', 'nvarchar(max)') as [positSuffix],
	[schema].value('schema[1]/metadata[1]/@annexSuffix', 'nvarchar(max)') as [annexSuffix],
	[schema].value('schema[1]/metadata[1]/@chronon', 'nvarchar(max)') as [chronon],
	[schema].value('schema[1]/metadata[1]/@now', 'nvarchar(max)') as [now],
	[schema].value('schema[1]/metadata[1]/@dummySuffix', 'nvarchar(max)') as [dummySuffix],
	[schema].value('schema[1]/metadata[1]/@statementTypeSuffix', 'nvarchar(max)') as [statementTypeSuffix],
	[schema].value('schema[1]/metadata[1]/@checksumSuffix', 'nvarchar(max)') as [checksumSuffix],
	[schema].value('schema[1]/metadata[1]/@businessViews', 'nvarchar(max)') as [businessViews],
	[schema].value('schema[1]/metadata[1]/@equivalence', 'nvarchar(max)') as [equivalence],
	[schema].value('schema[1]/metadata[1]/@equivalentSuffix', 'nvarchar(max)') as [equivalentSuffix],
	[schema].value('schema[1]/metadata[1]/@equivalentRange', 'nvarchar(max)') as [equivalentRange]
FROM
	_Schema;
GO
-- Anchor view --------------------------------------------------------------------------------------------------------
-- The anchor view shows information about all the anchors in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Anchor', 'V') IS NOT NULL
DROP VIEW [metadata].[_Anchor]
GO
CREATE VIEW [metadata].[_Anchor]
AS
SELECT
   S.version,
   S.activation,
   Nodeset.anchor.value('concat(@mnemonic, "_", @descriptor)', 'nvarchar(max)') as [name],
   Nodeset.anchor.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.anchor.value('@mnemonic', 'nvarchar(max)') as [mnemonic],
   Nodeset.anchor.value('@descriptor', 'nvarchar(max)') as [descriptor],
   Nodeset.anchor.value('@identity', 'nvarchar(max)') as [identity],
   Nodeset.anchor.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.anchor.value('count(attribute)', 'int') as [numberOfAttributes]
FROM
   [metadata].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/anchor') as Nodeset(anchor);
GO
-- Knot view ----------------------------------------------------------------------------------------------------------
-- The knot view shows information about all the knots in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Knot', 'V') IS NOT NULL
DROP VIEW [metadata].[_Knot]
GO
CREATE VIEW [metadata].[_Knot]
AS
SELECT
   S.version,
   S.activation,
   Nodeset.knot.value('concat(@mnemonic, "_", @descriptor)', 'nvarchar(max)') as [name],
   Nodeset.knot.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.knot.value('@mnemonic', 'nvarchar(max)') as [mnemonic],
   Nodeset.knot.value('@descriptor', 'nvarchar(max)') as [descriptor],
   Nodeset.knot.value('@identity', 'nvarchar(max)') as [identity],
   Nodeset.knot.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.knot.value('@dataRange', 'nvarchar(max)') as [dataRange],
   isnull(Nodeset.knot.value('metadata[1]/@checksum', 'nvarchar(max)'), 'false') as [checksum],
   isnull(Nodeset.knot.value('metadata[1]/@equivalent', 'nvarchar(max)'), 'false') as [equivalent]
FROM
   [metadata].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/knot') as Nodeset(knot);
GO
-- Attribute view -----------------------------------------------------------------------------------------------------
-- The attribute view shows information about all the attributes in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Attribute', 'V') IS NOT NULL
DROP VIEW [metadata].[_Attribute]
GO
CREATE VIEW [metadata].[_Attribute]
AS
SELECT
   S.version,
   S.activation,
   ParentNodeset.anchor.value('concat(@mnemonic, "_")', 'nvarchar(max)') +
   Nodeset.attribute.value('concat(@mnemonic, "_")', 'nvarchar(max)') +
   ParentNodeset.anchor.value('concat(@descriptor, "_")', 'nvarchar(max)') +
   Nodeset.attribute.value('@descriptor', 'nvarchar(max)') as [name],
   Nodeset.attribute.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.attribute.value('@mnemonic', 'nvarchar(max)') as [mnemonic],
   Nodeset.attribute.value('@descriptor', 'nvarchar(max)') as [descriptor],
   Nodeset.attribute.value('@identity', 'nvarchar(max)') as [identity],
   isnull(Nodeset.attribute.value('metadata[1]/@equivalent', 'nvarchar(max)'), 'false') as [equivalent],
   Nodeset.attribute.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.attribute.value('metadata[1]/@assertive', 'nvarchar(max)') as [assertive],
   isnull(Nodeset.attribute.value('metadata[1]/@checksum', 'nvarchar(max)'), 'false') as [checksum],
   Nodeset.attribute.value('metadata[1]/@restatable', 'nvarchar(max)') as [restatable],
   Nodeset.attribute.value('metadata[1]/@idempotent', 'nvarchar(max)') as [idempotent],
   ParentNodeset.anchor.value('@mnemonic', 'nvarchar(max)') as [anchorMnemonic],
   ParentNodeset.anchor.value('@descriptor', 'nvarchar(max)') as [anchorDescriptor],
   ParentNodeset.anchor.value('@identity', 'nvarchar(max)') as [anchorIdentity],
   Nodeset.attribute.value('@dataRange', 'nvarchar(max)') as [dataRange],
   Nodeset.attribute.value('@knotRange', 'nvarchar(max)') as [knotRange],
   Nodeset.attribute.value('@timeRange', 'nvarchar(max)') as [timeRange]
FROM
   [metadata].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/anchor') as ParentNodeset(anchor)
OUTER APPLY
   ParentNodeset.anchor.nodes('attribute') as Nodeset(attribute);
GO
-- Tie view -----------------------------------------------------------------------------------------------------------
-- The tie view shows information about all the ties in a schema
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Tie', 'V') IS NOT NULL
DROP VIEW [metadata].[_Tie]
GO
CREATE VIEW [metadata].[_Tie]
AS
SELECT
   S.version,
   S.activation,
   REPLACE(Nodeset.tie.query('
      for $role in *[local-name() = "anchorRole" or local-name() = "knotRole"]
      return concat($role/@type, "_", $role/@role)
   ').value('.', 'nvarchar(max)'), ' ', '_') as [name],
   Nodeset.tie.value('metadata[1]/@capsule', 'nvarchar(max)') as [capsule],
   Nodeset.tie.value('count(anchorRole) + count(knotRole)', 'int') as [numberOfRoles],
   Nodeset.tie.query('
      for $role in *[local-name() = "anchorRole" or local-name() = "knotRole"]
      return string($role/@role)
   ').value('.', 'nvarchar(max)') as [roles],
   Nodeset.tie.value('count(anchorRole)', 'int') as [numberOfAnchors],
   Nodeset.tie.query('
      for $role in anchorRole
      return string($role/@type)
   ').value('.', 'nvarchar(max)') as [anchors],
   Nodeset.tie.value('count(knotRole)', 'int') as [numberOfKnots],
   Nodeset.tie.query('
      for $role in knotRole
      return string($role/@type)
   ').value('.', 'nvarchar(max)') as [knots],
   Nodeset.tie.value('count(*[local-name() = "anchorRole" or local-name() = "knotRole"][@identifier = "true"])', 'int') as [numberOfIdentifiers],
   Nodeset.tie.query('
      for $role in *[local-name() = "anchorRole" or local-name() = "knotRole"][@identifier = "true"]
      return string($role/@type)
   ').value('.', 'nvarchar(max)') as [identifiers],
   Nodeset.tie.value('@timeRange', 'nvarchar(max)') as [timeRange],
   Nodeset.tie.value('metadata[1]/@generator', 'nvarchar(max)') as [generator],
   Nodeset.tie.value('metadata[1]/@assertive', 'nvarchar(max)') as [assertive],
   Nodeset.tie.value('metadata[1]/@restatable', 'nvarchar(max)') as [restatable],
   Nodeset.tie.value('metadata[1]/@idempotent', 'nvarchar(max)') as [idempotent]
FROM
   [metadata].[_Schema] S
CROSS APPLY
   S.[schema].nodes('/schema/tie') as Nodeset(tie);
GO
-- Evolution function -------------------------------------------------------------------------------------------------
-- The evolution function shows what the schema looked like at the given
-- point in time with additional information about missing or added
-- modeling components since that time.
--
-- @timepoint The point in time to which you would like to travel.
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._Evolution', 'IF') IS NOT NULL
DROP FUNCTION [metadata].[_Evolution];
GO
CREATE FUNCTION [metadata].[_Evolution] (
    @timepoint AS datetime2(7)
)
RETURNS TABLE
RETURN
SELECT
   V.[version],
   ISNULL(S.[name], T.[name]) AS [name],
   ISNULL(V.[activation], T.[create_date]) AS [activation],
   CASE
      WHEN S.[name] is null THEN
         CASE
            WHEN T.[create_date] > (
               SELECT
                  ISNULL(MAX([activation]), @timepoint)
               FROM
                  [metadata].[_Schema]
               WHERE
                  [activation] <= @timepoint
            ) THEN 'Future'
            ELSE 'Past'
         END
      WHEN T.[name] is null THEN 'Missing'
      ELSE 'Present'
   END AS Existence
FROM (
   SELECT
      MAX([version]) as [version],
      MAX([activation]) as [activation],
      MAX([temporalization]) as [temporalization]
   FROM
      [metadata].[_Schema_Expanded]
   WHERE
      [activation] <= @timepoint
) V
JOIN (
   SELECT
      temporalization,
      [capsule] + '.' + [name] + s.suffix AS [name],
      [version]
   FROM
      [metadata].[_Anchor] a
   CROSS APPLY (
      VALUES ('uni', ''), ('crt', '')
   ) s (temporalization, suffix)
   UNION ALL
   SELECT
      temporalization,
      [capsule] + '.' + [name] + s.suffix AS [name],
      [version]
   FROM
      [metadata].[_Knot] k
   CROSS APPLY (
      VALUES ('uni', ''), ('crt', '')
   ) s (temporalization, suffix)
   UNION ALL
   SELECT
      temporalization,
      [capsule] + '.' + [name] + s.suffix AS [name],
      [version]
   FROM
      [metadata].[_Attribute] b
   CROSS APPLY (
      VALUES ('uni', ''), ('crt', '_Annex'), ('crt', '_Posit')
   ) s (temporalization, suffix)
   UNION ALL
   SELECT
      temporalization,
      [capsule] + '.' + [name] + s.suffix AS [name],
      [version]
   FROM
      [metadata].[_Tie] t
   CROSS APPLY (
      VALUES ('uni', ''), ('crt', '_Annex'), ('crt', '_Posit')
   ) s (temporalization, suffix)
) S
ON
   S.[version] = V.[version]
AND
   S.temporalization = V.temporalization
FULL OUTER JOIN (
   SELECT 
      s.[name] + '.' + t.[name] AS [name],
      t.[create_date]
   FROM 
      sys.tables t
   JOIN
      sys.schemas s
   ON
      s.schema_id = t.schema_id
   WHERE
      t.[type] = 'U'
   AND
      LEFT(t.[name], 1) <> '_'
) T
ON
   S.[name] = T.[name];
GO
-- Drop Script Generator ----------------------------------------------------------------------------------------------
-- generates a drop script, that must be run separately, dropping everything in an Anchor Modeled database
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._GenerateDropScript', 'P') IS NOT NULL
DROP PROCEDURE [metadata].[_GenerateDropScript];
GO
CREATE PROCEDURE [metadata]._GenerateDropScript (
   @exclusionPattern varchar(42) = '[_]%', -- exclude Metadata by default
   @inclusionPattern varchar(42) = '%', -- include everything by default
   @directions varchar(42) = 'Upwards, Downwards', -- do both up and down by default
   @qualifiedName varchar(555) = null -- can specify a single object
)
AS
BEGIN
   with constructs as (
      select distinct
         0 as ordinal,
         '[' + capsule + '].[' + name + ']' as qualifiedName
      from
         [metadata]._Anchor
      union all
      select distinct
         1 as ordinal,
         '[' + capsule + '].[' + name + ']' as qualifiedName
      from
         [metadata]._Tie
      union all
      select distinct
         2 as ordinal,
         '[' + capsule + '].[' + name + '_Annex]' as qualifiedName
      from
         [metadata]._Tie
      union all
      select distinct
         3 as ordinal,
         '[' + capsule + '].[' + name + '_Posit]' as qualifiedName
      from
         [metadata]._Tie
      union all
      select distinct
         4 as ordinal,
         '[' + capsule + '].[' + name + ']' as qualifiedName
      from
         [metadata]._Attribute
      union all
      select distinct
         5 as ordinal,
         '[' + capsule + '].[' + name + '_Annex]' as qualifiedName
      from
         [metadata]._Attribute
      union all
      select distinct
         6 as ordinal,
         '[' + capsule + '].[' + name + '_Posit]' as qualifiedName
      from
         [metadata]._Attribute
      union all
      select distinct
         7 as ordinal,
         '[' + capsule + '].[' + name + ']' as qualifiedName
      from
         [metadata]._Knot
   ),
   includedConstructs as (
      select
         c.ordinal,
         cast(c.qualifiedName as nvarchar(517)) as qualifiedName,
         o.[object_id],
         o.[type]
      from
         constructs c
      join
         sys.objects o
      on
         o.object_id = OBJECT_ID(c.qualifiedName)
      where
         OBJECT_ID(c.qualifiedName) = OBJECT_ID(isnull(@qualifiedName, c.qualifiedName))
   ),
   relatedUpwards as (
      select
         c.[object_id],
         c.[type],
         c.qualifiedName,
         c.ordinal,
         1 as depth
      from
         includedConstructs c
      union all
      select
         o.[object_id],
         o.[type],
         n.qualifiedName,
         c.ordinal,
         c.depth + 1 as depth
      from
         relatedUpwards c
      cross apply
         sys.dm_sql_referencing_entities(c.qualifiedName, 'OBJECT') r
      cross apply (
         select
            cast('[' + r.referencing_schema_name + '].[' + r.referencing_entity_name + ']' as nvarchar(517))
      ) n (qualifiedName)
      join
         sys.objects o
      on
         o.object_id = r.referencing_id
      and
         o.type not in ('S')
   ),
   relatedDownwards as (
      select
         cast('Upwards' as varchar(42)) as [relationType],
         c.[object_id],
         c.[type],
         c.qualifiedName,
         c.ordinal,
         c.depth
      from
         relatedUpwards c 
      union all
      select
         cast('Downwards' as varchar(42)) as [relationType],
         o.[object_id],
         o.[type],
         n.qualifiedName,
         c.ordinal,
         c.depth - 1 as depth
      from
         relatedDownwards c
      cross apply
         sys.dm_sql_referenced_entities(c.qualifiedName, 'OBJECT') r
      cross apply (
         select
            cast('[' + r.referenced_schema_name + '].[' + r.referenced_entity_name + ']' as nvarchar(517))
      ) n (qualifiedName)
      join
         sys.objects o
      on
         o.object_id = r.referenced_id
      and
         o.type not in ('S')
      where
         r.referenced_minor_id = 0
      and 
         r.referenced_id <> OBJECT_ID(c.qualifiedName)
   ),
   affectedObjects as (
      select
         [object_id],
         [type],
         [qualifiedName],
         max([ordinal]) as ordinal,
         min([depth]) as depth
      from
         relatedDownwards
      where
         [qualifiedName] not like @exclusionPattern
      and
         [qualifiedName] like @inclusionPattern
      and
         @directions like '%' + [relationType] + '%'
      group by
         [object_id],
         [type],
         [qualifiedName]
   ),
   dropList as (
      select distinct
         objectType,
         qualifiedName,
         dropOrder
      from (
         select
            *,
            dense_rank() over (
               order by
                  case [type]
                     when 'TR' then 1 -- SQL_TRIGGER
                     when 'P' then 2 -- SQL_STORED_PROCEDURE
                     when 'V' then 3 -- VIEW
                     when 'IF' then 4 -- SQL_INLINE_TABLE_VALUED_FUNCTION
                     when 'FN' then 5 -- SQL_SCALAR_FUNCTION
                     when 'PK' then 6 -- PRIMARY_KEY_CONSTRAINT
                     when 'UQ' then 7 -- UNIQUE_CONSTRAINT
                     when 'F' then 8 -- FOREIGN_KEY_CONSTRAINT
                     when 'U' then 9 -- USER_TABLE
                  end asc,
                  ordinal asc,
                  depth desc
            ) as dropOrder
         from
            affectedObjects
         cross apply (
            select
               case [type]
                  when 'TR' then 'TRIGGER'
                  when 'V' then 'VIEW'
                  when 'IF' then 'FUNCTION'
                  when 'FN' then 'FUNCTION'
                  when 'P' then 'PROCEDURE'
                  when 'PK' then 'CONSTRAINT'
                  when 'UQ' then 'CONSTRAINT'
                  when 'F' then 'CONSTRAINT'
                  when 'U' then 'TABLE'
               end
         ) t (objectType)
         where
            t.objectType in (
               'VIEW',
               'FUNCTION',
               'PROCEDURE',
               'TABLE'
            )
      ) r
   )
   select
      'DROP ' + objectType + ' ' + qualifiedName + ';' + CHAR(13) as [text()]
   from
      dropList d
   order by
      dropOrder asc
   for xml path('');
END
GO
-- Database Copy Script Generator -------------------------------------------------------------------------------------
-- generates a copy script, that must be run separately, copying all data between two identically modeled databases
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._GenerateCopyScript', 'P') IS NOT NULL
DROP PROCEDURE [metadata].[_GenerateCopyScript];
GO
CREATE PROCEDURE [metadata]._GenerateCopyScript (
	@source varchar(123),
	@target varchar(123)
)
as
begin
	declare @R char(1);
    set @R = CHAR(13);
	-- stores the built SQL code
	declare @sql varchar(max);
    set @sql = 'USE ' + @target + ';' + @R;
	declare @xml xml;
	-- find which version of the schema that is in effect
	declare @version int;
	select
		@version = max([version])
	from
		_Schema;
	-- declare and set other variables we need
	declare @equivalentSuffix varchar(42);
	declare @identitySuffix varchar(42);
	declare @annexSuffix varchar(42);
	declare @positSuffix varchar(42);
	declare @temporalization varchar(42);
	select
		@equivalentSuffix = equivalentSuffix,
		@identitySuffix = identitySuffix,
		@annexSuffix = annexSuffix,
		@positSuffix = positSuffix,
		@temporalization = temporalization
	from
		_Schema_Expanded
	where
		[version] = @version;
	-- build non-equivalent knot copy
	set @xml = (
		select
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' ON;' + @R
			end,
			'INSERT INTO ' + [capsule] + '.' + [name] + '(' + [columns] + ')' + @R +
			'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + ';' + @R,
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' OFF;' + @R
			end
		from
			_Knot x
		cross apply (
			select stuff((
				select
					', ' + [name]
				from
					sys.columns
				where
					[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
				and
					is_computed = 0
				for xml path('')
			), 1, 2, '')
		) c ([columns])
		where
			[version] = @version
		and
			isnull(equivalent, 'false') = 'false'
		for xml path('')
	);
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	-- build equivalent knot copy
	set @xml = (
		select
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @identitySuffix + ' ON;' + @R
			end,
			'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @identitySuffix + '(' + [columns] + ')' + @R +
			'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @identitySuffix + ';' + @R,
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @identitySuffix + ' OFF;' + @R
			end,
			'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @equivalentSuffix + '(' + [columns] + ')' + @R +
			'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @equivalentSuffix + ';' + @R
		from
			_Knot x
		cross apply (
			select stuff((
				select
					', ' + [name]
				from
					sys.columns
				where
					[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
				and
					is_computed = 0
				for xml path('')
			), 1, 2, '')
		) c ([columns])
		where
			[version] = @version
		and
			isnull(equivalent, 'false') = 'true'
		for xml path('')
	);
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	-- build anchor copy
	set @xml = (
		select
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' ON;' + @R
			end,
			'INSERT INTO ' + [capsule] + '.' + [name] + '(' + [columns] + ')' + @R +
			'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + ';' + @R,
			case
				when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + ' OFF;' + @R
			end
		from
			_Anchor x
		cross apply (
			select stuff((
				select
					', ' + [name]
				from
					sys.columns
				where
					[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
				and
					is_computed = 0
				for xml path('')
			), 1, 2, '')
		) c ([columns])
		where
			[version] = @version
		for xml path('')
	);
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	-- build attribute copy
	if (@temporalization = 'crt')
	begin
		set @xml = (
			select
				case
					when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @positSuffix + ' ON;' + @R
				end,
				'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @positSuffix + '(' + [positColumns] + ')' + @R +
				'SELECT ' + [positColumns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @positSuffix + ';' + @R,
				case
					when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @positSuffix + ' OFF;' + @R
				end,
				'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @annexSuffix + '(' + [annexColumns] + ')' + @R +
				'SELECT ' + [annexColumns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @annexSuffix + ';' + @R
			from
				_Attribute x
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name] + '_' + @positSuffix)
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) pc ([positColumns])
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name] + '_' + @annexSuffix)
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) ac ([annexColumns])
			where
				[version] = @version
			for xml path('')
		);
	end
	else -- uni
	begin
		set @xml = (
			select
				'INSERT INTO ' + [capsule] + '.' + [name] + '(' + [columns] + ')' + @R +
				'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + ';' + @R
			from
				_Attribute x
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) c ([columns])
			where
				[version] = @version
			for xml path('')
		);
	end
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	-- build tie copy
	if (@temporalization = 'crt')
	begin
		set @xml = (
			select
				case
					when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @positSuffix + ' ON;' + @R
				end,
				'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @positSuffix + '(' + [positColumns] + ')' + @R +
				'SELECT ' + [positColumns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @positSuffix + ';' + @R,
				case
					when [generator] = 'true' then 'SET IDENTITY_INSERT ' + [capsule] + '.' + [name] + '_' + @positSuffix + ' OFF;' + @R
				end,
				'INSERT INTO ' + [capsule] + '.' + [name] + '_' + @annexSuffix + '(' + [annexColumns] + ')' + @R +
				'SELECT ' + [annexColumns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + '_' + @annexSuffix + ';' + @R
			from
				_Tie x
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name] + '_' + @positSuffix)
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) pc ([positColumns])
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name] + '_' + @annexSuffix)
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) ac ([annexColumns])
			where
				[version] = @version
			for xml path('')
		);
	end
	else -- uni
	begin
		set @xml = (
			select
				'INSERT INTO ' + [capsule] + '.' + [name] + '(' + [columns] + ')' + @R +
				'SELECT ' + [columns] + ' FROM ' + @source + '.' + [capsule] + '.' + [name] + ';' + @R
			from
				_Tie x
			cross apply (
				select stuff((
					select
						', ' + [name]
					from
						sys.columns
					where
						[object_Id] = object_Id(x.[capsule] + '.' + x.[name])
					and
						is_computed = 0
					for xml path('')
				), 1, 2, '')
			) c ([columns])
			where
				[version] = @version
			for xml path('')
		);
	end
	set @sql = @sql + isnull(@xml.value('.', 'varchar(max)'), '');
	select @sql for xml path('');
end
go
-- Delete Everything with a Certain Metadata Id -----------------------------------------------------------------------
-- deletes all rows from all tables that have the specified metadata id
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('metadata._DeleteWhereMetadataEquals', 'P') IS NOT NULL
DROP PROCEDURE [metadata].[_DeleteWhereMetadataEquals];
GO
CREATE PROCEDURE [metadata]._DeleteWhereMetadataEquals (
	@metadataID int,
	@schemaVersion int = null,
	@includeKnots bit = 0
)
as
begin
	declare @sql varchar(max);
	set @sql = 'print ''Null is not a valid value for @metadataId''';
	if(@metadataId is not null)
	begin
		if(@schemaVersion is null)
		begin
			select
				@schemaVersion = max(Version)
			from
				_Schema;
		end;
		with constructs as (
			select
				'l' + name as name,
				2 as prio,
				'Metadata_' + name as metadataColumn
			from
				_Tie
			where
				[version] = @schemaVersion
			union all
			select
				'l' + name as name,
				3 as prio,
				'Metadata_' + mnemonic as metadataColumn
			from
				_Anchor
			where
				[version] = @schemaVersion
			union all
			select
				name,
				4 as prio,
				'Metadata_' + mnemonic as metadataColumn
			from
				_Knot
			where
				[version] = @schemaVersion
			and
				@includeKnots = 1
		)
		select
			@sql = (
				select
					'DELETE FROM ' + name + ' WHERE ' + metadataColumn + ' = ' + cast(@metadataId as varchar(10)) + '; '
				from
					constructs
        order by
					prio, name
				for xml
					path('')
			);
	end
	exec(@sql);
end
go
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------