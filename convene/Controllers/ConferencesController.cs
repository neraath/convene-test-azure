using System.Collections.Generic;
using System.Web.Http;
using convene.Models;

namespace convene.Controllers
{
    public class ConferencesController : ApiController
    {
        private IEventRepository repo;

        public ConferencesController()
        {
        }

        public ConferencesController(IEventRepository eventRepository)
        {
            repo = eventRepository;
        }

        // GET api/conferences
        public IEnumerable<Event> Get()
        {
            return repo.GetEvents();
        }

        // GET api/conferences/5
        public string Get(int id)
        {
            return "value";
        }

        // POST api/conferences
        public void Post([FromBody]string value)
        {
        }

        // PUT api/conferences/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE api/conferences/5
        public void Delete(int id)
        {
        }
    }
}
