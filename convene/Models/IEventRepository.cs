using System.Collections.Generic;

namespace convene.Models
{
    public interface IEventRepository
    {
        IEnumerable<Event> GetEvents();
    }
}