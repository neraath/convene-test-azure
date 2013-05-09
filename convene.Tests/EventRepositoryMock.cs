using System.Collections.Generic;
using convene.Models;

namespace convene.Tests
{
    public class EventRepositoryMock : IEventRepository
    {
        public EventRepositoryMock(IList<Event> eventsToPrime)
        {
            Events = eventsToPrime;
        }

        public IList<Event> Events { get; private set; }

        public IEnumerable<Event> GetEvents()
        {
            return Events;
        }
    }
}
