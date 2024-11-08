// src/components/BannerCarousel.jsx
import React from 'react';
import { Carousel } from 'react-bootstrap';

const BannerCarousel = () => {
  return (
    <Carousel>
      <Carousel.Item>
        <img
          className="d-block w-100"
          src="/assets/images/slide-1.jpg"
          alt="First slide"
        />
      </Carousel.Item>

      <Carousel.Item>
        <img
          className="d-block w-100"
          src="/assets/images/slide-2.jpg"
          alt="Second slide"
        />
      </Carousel.Item>

      <Carousel.Item>
        <img
          className="d-block w-100"
          src="/assets/images/slide-3.jpg"
          alt="Third slide"
        />
      </Carousel.Item>

      <Carousel.Item>
        <img
          className="d-block w-100"
          src="/assets/images/slide-4.jpg"
          alt="Fourth slide"
        />
      </Carousel.Item>

    </Carousel>
  );
};

export default BannerCarousel;