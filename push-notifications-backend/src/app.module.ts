import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { FcmModule } from './fcm/fcm.module';

@Module({
  imports: [
    // Loads variables from .env into process.env and makes ConfigService global
    ConfigModule.forRoot({ isGlobal: true }),
    FcmModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
