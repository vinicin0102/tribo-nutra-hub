import { useState, useRef, useEffect } from 'react';
import { Play, Pause } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';

interface AudioPlayerProps {
  audioUrl: string;
  duration?: number;
  isOwn?: boolean;
}

export function AudioPlayer({ audioUrl, duration, isOwn = false }: AudioPlayerProps) {
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [audioDuration, setAudioDuration] = useState(duration || 0);
  const audioRef = useRef<HTMLAudioElement>(null);

  useEffect(() => {
    const audio = audioRef.current;
    if (!audio) return;

    const updateTime = () => setCurrentTime(audio.currentTime);
    const updateDuration = () => setAudioDuration(audio.duration);
    const handleEnded = () => setIsPlaying(false);

    audio.addEventListener('timeupdate', updateTime);
    audio.addEventListener('loadedmetadata', updateDuration);
    audio.addEventListener('ended', handleEnded);

    return () => {
      audio.removeEventListener('timeupdate', updateTime);
      audio.removeEventListener('loadedmetadata', updateDuration);
      audio.removeEventListener('ended', handleEnded);
    };
  }, []);

  const togglePlay = () => {
    const audio = audioRef.current;
    if (!audio) return;

    if (isPlaying) {
      audio.pause();
    } else {
      audio.play();
    }
    setIsPlaying(!isPlaying);
  };

  const formatTime = (time: number) => {
    if (isNaN(time)) return '0:00';
    const minutes = Math.floor(time / 60);
    const seconds = Math.floor(time % 60);
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  };

  const progress = audioDuration > 0 ? (currentTime / audioDuration) * 100 : 0;

  return (
    <div className="flex items-center gap-2 min-w-[200px] max-w-[280px]">
      <audio ref={audioRef} src={audioUrl} preload="metadata" />
      
      <Button
        type="button"
        variant="ghost"
        size="icon"
        onClick={togglePlay}
        className={cn(
          "h-8 w-8 rounded-full flex-shrink-0",
          isOwn 
            ? "bg-white/20 hover:bg-white/30 text-white" 
            : "bg-primary/20 hover:bg-primary/30 text-primary"
        )}
      >
        {isPlaying ? (
          <Pause className="h-4 w-4 fill-current" />
        ) : (
          <Play className="h-4 w-4 fill-current ml-0.5" />
        )}
      </Button>

      <div className="flex-1 space-y-1">
        <div className="relative h-1 bg-white/20 rounded-full overflow-hidden">
          <div 
            className={cn(
              "absolute left-0 top-0 h-full rounded-full transition-all",
              isOwn ? "bg-white/60" : "bg-primary/60"
            )}
            style={{ width: `${progress}%` }}
          />
        </div>
        <div className={cn(
          "text-[10px]",
          isOwn ? "text-white/70" : "text-gray-500"
        )}>
          {isPlaying ? formatTime(currentTime) : formatTime(audioDuration)}
        </div>
      </div>
    </div>
  );
}

