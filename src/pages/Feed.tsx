import { MainLayout } from '@/components/layout/MainLayout';
import { CreatePostCard } from '@/components/feed/CreatePostCard';
import { PostCard } from '@/components/feed/PostCard';
import { usePosts } from '@/hooks/usePosts';
import { Skeleton } from '@/components/ui/skeleton';

export default function Feed() {
  const { data: posts, isLoading } = usePosts();

  return (
    <MainLayout>
      <div className="max-w-xl mx-auto">
        <CreatePostCard />

        {isLoading ? (
          <div className="space-y-4">
            {[1, 2, 3].map((i) => (
              <div key={i} className="rounded-lg border bg-card p-4">
                <div className="flex items-center gap-3 mb-4">
                  <Skeleton className="h-10 w-10 rounded-full" />
                  <div className="space-y-2">
                    <Skeleton className="h-4 w-24" />
                    <Skeleton className="h-3 w-16" />
                  </div>
                </div>
                <Skeleton className="h-20 w-full mb-3" />
                <Skeleton className="h-8 w-full" />
              </div>
            ))}
          </div>
        ) : posts && posts.length > 0 ? (
          posts.map((post) => <PostCard key={post.id} post={post} />)
        ) : (
          <div className="text-center py-12">
            <div className="inline-flex items-center justify-center gradient-primary rounded-2xl p-4 mb-4">
              <span className="text-4xl">📝</span>
            </div>
            <h3 className="font-display text-lg font-semibold mb-2">
              Nenhuma publicação ainda
            </h3>
            <p className="text-muted-foreground text-sm">
              Seja o primeiro a compartilhar sua evolução!
            </p>
          </div>
        )}
      </div>
    </MainLayout>
  );
}
