using Microsoft.EntityFrameworkCore;
using dotnet_func.Models;

namespace dotnet_func.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options)
        {
        }

        public DbSet<User> Users { get; set; } = default!;
        public DbSet<Meal> Meals { get; set; } = default!;
        public DbSet<Activity> Activities { get; set; } = default!;
        public DbSet<WeightLog> WeightLogs { get; set; } = default!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // ======================
            // USER
            // ======================
            modelBuilder.Entity<User>()
                .HasKey(u => u.Id);

            modelBuilder.Entity<User>()
                .Property(u => u.Gender)
                .HasConversion<string>();

            modelBuilder.Entity<User>()
                .Property(u => u.ActivityLevel)
                .HasConversion<string>();

            modelBuilder.Entity<User>()
                .Property(u => u.Allergies)
                .HasColumnType("text[]");

            // ======================
            // MEAL
            // ======================
            modelBuilder.Entity<Meal>()
                .HasKey(m => m.Id);

            modelBuilder.Entity<Meal>()
                .HasOne(m => m.User)
                .WithMany(u => u.Meals)
                .HasForeignKey(m => m.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Meal>()
                .Property(m => m.MealType)
                .HasConversion<string>();

            // ======================
            // ACTIVITY
            // ======================
            modelBuilder.Entity<Activity>()
                .HasKey(a => a.Id);

            modelBuilder.Entity<Activity>()
                .HasOne(a => a.User)
                .WithMany(u => u.Activities)
                .HasForeignKey(a => a.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Activity>()
                .Property(a => a.Type)
                .HasConversion<string>();

            // ======================
            // WEIGHT LOG
            // ======================
            modelBuilder.Entity<WeightLog>()
                .HasKey(w => w.Id);

            modelBuilder.Entity<WeightLog>()
                .HasOne(w => w.User)
                .WithMany(u => u.WeightLogs)
                .HasForeignKey(w => w.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
