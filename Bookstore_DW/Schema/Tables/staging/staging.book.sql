CREATE TABLE [staging].[book] (
    [book_id]           INT           NULL,
    [title]             VARCHAR (400) NULL,
    [isbn13]            VARCHAR (13)  NULL,
    [language_code]     VARCHAR (8)   NULL,
    [language_name]     VARCHAR (50)  NULL,
    [num_pages]         INT           NULL,
    [publication_date]  DATE          NULL,
    [publisher_name]    VARCHAR (400) NULL,
    [author_name]       VARCHAR (400) NULL,
    [staging_load_date] DATETIME      NOT NULL DEFAULT (GETDATE())
);
-- Columnas alineadas 1:1 con la salida de [dbo].[GetBookChangesByRowVersion]
