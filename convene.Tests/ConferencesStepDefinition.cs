using System;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;
using TechTalk.SpecFlow;
using convene.Controllers;
using convene.Models;

namespace convene.Tests
{
    [Binding]
    public class ConferencesStepDefinition
    {
        private const string EventName = "Name";
        private const string EventDescription = "Description";
        private const string EventStartDate = "StartDate";

        private IList<Event> conferenceEvents;
        private EventRepositoryMock eventRepo;
        private ConferencesController controller;

        private object result;

        [BeforeScenario]
        public void Initialize()
        {
            conferenceEvents = new List<Event>();
            eventRepo = new EventRepositoryMock(conferenceEvents);
            controller = new ConferencesController(eventRepo);
        }

        [Given("I have the following conferences:")]
        public void GivenIHaveConferences(Table conferences)
        {
            foreach (var conference in conferences.Rows)
            {
                var evt = new Event()
                    {
                        Name = conference[EventName],
                        Description = conference[EventDescription],
                        StartDate = DateTime.Parse(conference[EventStartDate])
                    };
                eventRepo.Events.Add(evt);
            }
        }

        [When("I ([a-zA-Z]*) the resource (.*)")]
        public void WhenIOperateOnTheResource(string operation, string resourceName)
        {
            result = controller.Get();
        }

        [Then("the result should contain ([0-9]*) (.*) resources")]
        public void ThenTheResultShouldBe(int count, string resourceName)
        {
            Assert.IsInstanceOf<IEnumerable<Event>>(result);
            Assert.AreEqual(count, ((IEnumerable<Event>) result).Count(), "Count of resources is not equal.");
        }
    }
}
