<?php

namespace App\DataFixtures;

use App\Entity\Posts;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Faker\Factory;

class AppFixtures extends Fixture
{
    public function load(ObjectManager $manager)
    {
        $faker = Factory::create();

        for ($i = 1; $i <= 10; $i++) {
            $post = (new Posts())
                ->setTitle($faker->realText())
                ->setSlug($faker->slug)
                ->setContent($faker->realText(1_000))
                ->setCreatedAt($faker->dateTimeBetween('-5 years'))
                ->setCreatedAt($faker->dateTimeBetween('-3 years', '1 year'))
            ;
            $manager->persist($post);
        }

        $manager->flush();
    }
}
