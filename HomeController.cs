using Microsoft.AspNetCore.Mvc;
using RaceDay.Part1.Models;

namespace RaceDay.Part1.Controllers;

public class HomeController : Controller
{
    public IActionResult Index() => View();

    public IActionResult Erd() => View(BuildEntities());
    public IActionResult Endpoints() => View(BuildEndpoints());
    public IActionResult Sql() => View();

    private static List<EntityModel> BuildEntities() => new()
    {
        new("Users", "Stores organisers and participants in one account table.", new[]{"UserId (PK)"}, new[]{"UserId", "FirstName", "LastName", "Email (UNIQUE)", "PasswordHash", "Role", "Phone", "CreatedAt"}),
        new("Events", "Race events created and managed by organisers.", new[]{"EventId (PK)", "OrganiserId (FK)"}, new[]{"EventId", "OrganiserId", "Name", "Description", "Venue", "EventDate", "RegistrationOpen", "RegistrationClose", "Status", "CreatedAt"}),
        new("Categories", "Race categories such as 5 km, 10 km and marathon.", new[]{"CategoryId (PK)"}, new[]{"CategoryId", "Name", "DistanceKm", "MaxParticipants"}),
        new("EventCategories", "Associative entity implementing the event/category many-to-many relationship.", new[]{"EventId (PK, FK)", "CategoryId (PK, FK)"}, new[]{"EventId", "CategoryId", "EntryFee"}),
        new("Enrolments", "Links a participant to an event category.", new[]{"EnrolmentId (PK)", "ParticipantId (FK)", "EventId (FK)", "CategoryId (FK)"}, new[]{"EnrolmentId", "ParticipantId", "EventId", "CategoryId", "EnrolmentDate", "Status", "RaceNumber"}),
        new("Results", "Stores the finishing result for an enrolment.", new[]{"ResultId (PK)", "EnrolmentId (FK)"}, new[]{"ResultId", "EnrolmentId", "FinishTime", "Position", "ResultStatus", "RecordedAt"}),
        new("UserProfiles", "Optional profile details separated from authentication data.", new[]{"ProfileId (PK)", "UserId (FK, UNIQUE)"}, new[]{"ProfileId", "UserId", "DateOfBirth", "Gender", "EmergencyContactName", "EmergencyContactPhone", "Address"})
    };

    private static List<EndpointModel> BuildEndpoints() => new()
    {
        new("POST", "/api/auth/register", "Creates a new participant or organiser account after validating the email and role.", "Public", "firstName, lastName, email, password, role", "201 Created with userId and token; 400 validation error; 409 email already exists."),
        new("POST", "/api/auth/login", "Authenticates a registered user and returns an access token.", "Public", "email, password", "200 OK with token and user details; 401 invalid credentials."),
        new("GET", "/api/profile", "Returns the logged-in user's profile.", "Logged-in", "None", "200 OK with profile; 401 unauthorised."),
        new("PUT", "/api/profile", "Updates the logged-in user's profile and contact information.", "Logged-in", "profile fields", "200 OK updated profile; 400 validation error."),
        new("GET", "/api/events", "Lists available events with optional filters.", "Public", "Query parameters: date, status", "200 OK with event collection."),
        new("GET", "/api/events/{id}", "Returns details for one event, including its categories.", "Public", "None", "200 OK event; 404 event not found."),
        new("POST", "/api/events", "Creates a new race event and assigns the logged-in organiser as owner.", "Organiser", "name, description, venue, eventDate, registrationOpen, registrationClose, status", "201 Created event; 400 validation error; 403 forbidden."),
        new("PUT", "/api/events/{id}", "Updates an event owned by the organiser.", "Organiser", "Editable event fields", "200 OK updated event; 403 forbidden; 404 not found."),
        new("DELETE", "/api/events/{id}", "Removes an event that has not started and is owned by the organiser.", "Organiser", "None", "204 No Content; 403 forbidden; 404 not found; 409 conflict."),
        new("GET", "/api/categories", "Lists all race categories.", "Public", "None", "200 OK category collection."),
        new("POST", "/api/events/{eventId}/categories", "Adds a category to an event.", "Organiser", "categoryId, entryFee", "201 Created association; 404 not found; 409 duplicate."),
        new("DELETE", "/api/events/{eventId}/categories/{categoryId}", "Removes a category from an event when it has no enrolments.", "Organiser", "None", "204 No Content; 409 conflict if enrolments exist."),
        new("POST", "/api/events/{eventId}/enrolments", "Enrols the logged-in participant into a category for an event.", "Participant", "categoryId", "201 Created enrolment with raceNumber; 400 invalid category; 409 closed/full/duplicate."),
        new("GET", "/api/enrolments", "Returns the logged-in participant's enrolments.", "Participant", "None", "200 OK enrolment collection."),
        new("GET", "/api/events/{eventId}/enrolments", "Returns enrolments for an organiser's event.", "Organiser", "None", "200 OK enrolments; 403 forbidden; 404 not found."),
        new("DELETE", "/api/enrolments/{id}", "Cancels a participant's enrolment before the registration deadline.", "Participant", "None", "204 No Content; 404 not found; 409 deadline passed."),
        new("GET", "/api/events/{eventId}/results", "Returns published results for an event ordered by position.", "Public", "None", "200 OK result collection."),
        new("POST", "/api/events/{eventId}/results", "Records a finishing result for a participant enrolment.", "Organiser", "enrolmentId, finishTime, position, resultStatus", "201 Created result; 400 invalid data; 403 forbidden; 409 result exists."),
        new("PUT", "/api/results/{id}", "Corrects an existing result recorded for an organiser's event.", "Organiser", "finishTime, position, resultStatus", "200 OK updated result; 403 forbidden; 404 not found."),
        new("GET", "/api/results/{id}", "Returns one published result.", "Public", "None", "200 OK result; 404 not found.")
    };
}
