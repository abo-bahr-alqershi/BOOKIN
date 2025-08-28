using System;
using System.Collections.Generic;

namespace YemenBooking.Application.DTOs
{
    /// <summary>
    /// DTO for City settings
    /// </summary>
    public class CityDto
    {
        /// <summary>City name (unique)</summary>
        public string Name { get; set; }

        /// <summary>Country name</summary>
        public string Country { get; set; }

        /// <summary>Image URLs for the city</summary>
        public List<string> Images { get; set; } = new List<string>();
    }
} 