CREATE TABLE [dbo].[DimBook] (
    [BookKey]          INT           IDENTITY (1, 1) NOT NULL,
    [BookID]           INT           NOT NULL,   -- llave de negocio (dbo.book.book_id)
    [Title]            VARCHAR (400) NULL,
    [ISBN13]           VARCHAR (13)  NULL,
    [NumPages]         INT           NULL,
    [PublicationDate]  DATE          NULL,
    [LanguageCode]     VARCHAR (8)   NULL,
    [LanguageName]     VARCHAR (50)  NULL,
    [PublisherName]    VARCHAR (400) NULL,
    [AuthorName]       VARCHAR (400) NULL,   -- autor(es), concatenados si hay mas de uno
    CONSTRAINT [pk_DimBook] PRIMARY KEY CLUSTERED ([BookKey] ASC)
);
