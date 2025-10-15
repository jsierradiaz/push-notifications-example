import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common';
import { FcmService } from './fcm.service';
import { SendMessageDto } from './dto/send-message.dto';

@Controller('fcm')
export class FcmController {
  constructor(private readonly fcmService: FcmService) {}

  @Post('send')
  @HttpCode(HttpStatus.OK)
  async send(@Body() dto: SendMessageDto) {
    const res = await this.fcmService.send({
      token: dto.token,
      notification:
        dto.title || dto.body
          ? { title: dto.title, body: dto.body }
          : undefined,
      data: dto.data,
    });
    return res;
  }
}
