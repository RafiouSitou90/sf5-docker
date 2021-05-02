<?php

namespace App\Tests\Controller;

use App\DataFixtures\AppFixtures;
use Liip\TestFixturesBundle\Test\FixturesTrait;
use Symfony\Bundle\FrameworkBundle\KernelBrowser;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Generator\UrlGeneratorInterface;

class HomeControllerTest extends WebTestCase
{
    use FixturesTrait;

    private KernelBrowser $client;
    private UrlGeneratorInterface $urlGenerator;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        /** @var UrlGeneratorInterface $urlGene */
        $urlGene = self::$container->get(UrlGeneratorInterface::class);
        $this->urlGenerator = $urlGene;

        $this->loadFixtures([AppFixtures::class]);
        parent::setUp();
    }

    public function testGetHomepageSuccessfully(): void
    {
        $route = $this->urlGenerator->generate('home');
        $this->client->request('GET', $route);

        self::assertResponseIsSuccessful();
        self::assertResponseStatusCodeSame(Response::HTTP_OK);
        self::assertPageTitleContains('Hello HomeController!');
    }
}
