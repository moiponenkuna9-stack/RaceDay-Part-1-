using Microsoft.AspNetCore.StaticFiles;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllersWithViews();
var app = builder.Build();
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
}

// .sql is not a recognised static file type by default, so ASP.NET Core
// refuses to serve it (silent 404). Register it explicitly.
var contentTypeProvider = new FileExtensionContentTypeProvider();
contentTypeProvider.Mappings[".sql"] = "text/plain";
app.UseStaticFiles(new StaticFileOptions
{
    ContentTypeProvider = contentTypeProvider
});

app.UseRouting();
app.MapControllerRoute(name: "default", pattern: "{controller=Home}/{action=Index}/{id?}");
app.Run();
