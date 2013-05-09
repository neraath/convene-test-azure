using System.Collections.Generic;

namespace convene.Models
{
    public class StaticEventRepository : IEventRepository
    {
        public StaticEventRepository()
        {
            Events = new List<Event>();
        }

        public static IList<Event> Events { get; private set; }

        public IEnumerable<Event> GetEvents()
        {
            return Events;
        }
    }
}