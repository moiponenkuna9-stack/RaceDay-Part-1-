namespace RaceDay.Part1.Models;

public record EntityModel(string Name, string Description, string[] KeyFields, string[] Fields);
public record EndpointModel(string Method, string Route, string Description, string Role, string Body, string Response);
