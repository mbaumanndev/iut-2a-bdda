using DUT2._2021.Orm.Models;
using Microsoft.EntityFrameworkCore;

namespace DUT2._2021.Orm
{
    public static class SeedData
    {
        public static void Initialize(IServiceProvider sp)
        {
            using var context = new TodoContext(sp.GetRequiredService<DbContextOptions<TodoContext>>());

            context.Database.EnsureCreated();

            if (!context.TodoItems.Any())
            {
                context.TodoItems.Add(new TodoItem
                {
                    IsComplete = false,
                    Name = "Faire une démo"
                });

                context.SaveChanges();
            }
        }
    }
}
