<?php

namespace App\Tests\Entity;

use App\Entity\Posts;
use App\Repository\PostsRepository;
use DateTimeInterface;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;

class PostsTest extends KernelTestCase
{
    private EntityManagerInterface $entityManager;

    protected function setUp(): void
    {
        self::bootKernel();

        /** @var EntityManagerInterface $em */
        $em = self::$container->get(EntityManagerInterface::class);
        $this->entityManager = $em;

        parent::setUp();
    }
    
    public function testPost(): void
    {
        $post = $this->getPost();

        self::assertSame('Post title', $post->getTitle());
        self::assertSame('post-title', $post->getSlug());
        self::assertSame('Post content', $post->getContent());
        self::assertNotNull($post->getCreatedAt());
        self::assertInstanceOf(DateTimeInterface::class, $post->getCreatedAt());
        self::assertNotNull($post->getUpdatedAt());
        self::assertInstanceOf(DateTimeInterface::class, $post->getUpdatedAt());
    }

    public function testSavePosts(): void
    {
        $post = $this->getPost();
        $this->entityManager->persist($post);
        $this->entityManager->flush();
        
        $postAdded = $this->getRepository()->findBy(['title' => 'Post title']);

        self::assertNotNull($postAdded);
    }

    private function getPost(): Posts
    {
        return (new Posts)
            ->setTitle('Post title')
            ->setSlug('post-title')
            ->setContent('Post content')
        ;
    }

    private function getRepository(): PostsRepository
    {
        /** @var PostsRepository $postsRepo */
        $postsRepo = $this->entityManager->getRepository(Posts::class);

        return $postsRepo;
    }
}
